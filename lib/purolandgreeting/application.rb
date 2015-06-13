require 'set'

module PurolandGreeting
  class Application < Sinatra::Base
    set :session, false

    set :root, PurolandGreeting.root

    set :assets_prefix, '/assets'
    set :sprockets, Sprockets::Environment.new

    set :haml, format: :html5, attr_quote: '"'

    configure :development do
      Bundler.require :development
      register Sinatra::Reloader
    end

    configure do
      Database.connect

      Sprockets::Sass.options = {
        :style => (production? ? :compressed : :nested),
      }
      Sprockets::Helpers.configure do |config|
        config.environment = Application.sprockets
        config.public_path = public_folder
        config.prefix = assets_prefix
        config.digest = true
      end

      sprockets.append_path 'assets/images'
      sprockets.append_path 'assets/javascripts'
      sprockets.append_path 'assets/stylesheets'
      RailsAssets.load_paths.each do |path|
        sprockets.append_path path
      end
    end

    helpers Sprockets::Helpers

    helpers do
      def calendar(month, &block)
        next_month = month >> 1
        days = [ nil ] * month.wday + (1..(next_month - month)).to_a + [ nil ] * ((7 - next_month.wday) % 7)
        workdays = Schedule.where('date >= ? AND date < ?', month, next_month).pluck(:date).to_set
        first = Schedule.order('date ASC').first.date
        last = Schedule.order('date ASC').last.date

        haml :'_partial/calendar', layout: false, locals: {
          month: month,
          days: days,
          workdays: workdays,
          first: first,
          last: last,
          block: block,
        }
      end
    end

    get '/' do
      today = Date.today
      today_schedule = Schedule.find_by_date(today)
      temporary_schedule = today_schedule ? TemporarySchedule.where('date > ?', today).order('date ASC').first : TemporarySchedule.where('date >= ? ', today).order('date DESC').first
      haml :index, locals: {
        today: today,
        today_schedule: today_schedule,
        temporary_schedule: temporary_schedule,
      }
    end

    get '/official/attraction/today' do
      redirect "http://www.puroland.jp/pdf/schedule/#{Date.today.strftime('%Y%m%d')}.pdf"
    end

    get '/export' do
      content_type 'text/ltsv'
      Database.export
    end

    get '/schedule/today' do
      date = Date.today
      schedule = Schedule.where('date = ?', date).first
      if schedule
        redirect date.strftime('/schedule/%Y/%m/%d/')
      else
        redirect '/'
      end
    end

    get '/schedule/' do
      months = Schedule.months
      schedules = Schedule.order('date DESC')
      haml :schedules, locals: {
        months: months,
        schedules: schedules,
      }
    end

    get %r{\A/schedule/(\d{4})/(\d{2})/(\d{2})/\z} do |year, month, day|
      date = Date.new(year.to_i, month.to_i, day.to_i)
      schedule = Schedule.where('date = ?', date).first or not_found
      characters = schedule.characters.uniq
      greetings = schedule.greetings.active.eager_load(:place)
      time = Time.now
      @title = "#{date.strftime('%Y/%m/%d')} の予定"
      @description = "登場キャラクター: #{characters.map(&:name).join(' ')}"[0, 200]
      haml :schedule, locals: {
        schedule: schedule,
        characters: characters,
        greetings: greetings,
        before_the_start: greetings.before_the_start(time),
        in_session: greetings.in_session(time),
        after_the_end: greetings.after_the_end(time),
        deleted: schedule.greetings.deleted
      }
    end

    get %r{\A/schedule/(\d{4})/(\d{2})/(\d{2})/character\z} do |year, month, day|
      date = Date.new(year.to_i, month.to_i, day.to_i)
      temporary_schedule = TemporarySchedule.find_by_date(date) or not_found
      today_schedule = Schedule.find_by_date(date)
      characters = temporary_schedule.characters.where('temporary_appearances.deleted = false')
      deleted_characters = temporary_schedule.characters.where('temporary_appearances.deleted = true')
      @title = "#{date.strftime('%Y/%m/%d')} の登場キャラクター"
      @description = "登場キャラクター: #{characters.map(&:name).join(' ')}"[0, 200]
      haml :temporary_schedule, locals: {
        today_schedule: today_schedule,
        temporary_schedule: temporary_schedule,
        characters: characters,
        deleted_characters: deleted_characters,
      }
    end

    get '/character/' do
      characters = Character.order('name ASC')
      haml :characters, locals: {
        characters: characters,
      }
    end

    get %r{\A/character/([^/]+)/\z} do |name|
      today = Date.today
      character = Character.where('name = ?', name).first or not_found

      timespans = [
        { label: '1週間以内', from: today - 7, },
        { label: '1ヶ月以内', from: today << 1, },
        { label: '3ヶ月以内', from: today << 3, },
        { label: '6ヶ月以内', from: today << 6, },
        { label: '1年以内',   from: today << 12, },
      ].map {|item|
        from = item[:from]
        greetings = character.greetings.active
        a = greetings.active.joins(:schedule).where('schedules.date > ?', from)
        appearances = a.count('DISTINCT schedules.date')
        dates = Schedule.where('date > ?', from).count('DISTINCT date')
        appearance_dates = a.count
        appearance_probability = dates > 0 ? Rational(appearances, dates) : 0
        item.merge(
          appearances: appearances,
          dates: dates,
          appearance_dates: appearance_dates,
          appearance_probability: appearance_probability)
      }

      greetings_by_month = character.greetings.active.joins(:schedule).order("year, month").group("year, month").select("DATE_PART('year', date) AS year, DATE_PART('month', date) AS month, COUNT(greetings.id) AS count")

      places = character.place_ranking

      @title = character.name
      haml :character, locals: {
        today: today,
        character: character,
        timespans: timespans,
        greetings_by_month: {
          columns: [
            { type: 'string', name: '月', },
            { type: 'number', name: '登場回数', },
          ],
          rows: greetings_by_month.map {|item|
            [ "#{item.year.to_i}/#{item.month.to_i}", item.count.to_i, ]
          },
        }.to_json,
        places: {
          columns: [
            { type: 'string', name: '場所', },
            { type: 'number', name: '登場回数', },
          ],
          rows: places.map {|item|
            [ item.name, item.score, ]
          },
        }.to_json,
      }
    end

    get '/statistics/' do
      count_by_month = Appearance.count_by_month
      ranking = Character.ranking

      @title = '統計'
      haml :statistics, locals: {
        count_by_month: {
          columns: [
            { type: 'string', name: '月', },
            { type: 'number', name: '登場回数', },
          ],
          rows: count_by_month.map {|item|
            [ "#{item.year}/#{item.month}", item.appearances, ]
          },
        }.to_json,
        ranking: {
          columns: [
            { type: 'string', name: 'キャラクター', },
            { type: 'number', name: '登場回数', },
          ],
          rows: ranking.map {|item|
            [ item.name, item.score, ]
          },
        }.to_json,
      }
    end

  end
end
