require 'set'

module PurolandGreeting
  class Application < Sinatra::Base
    register Sinatra::ActiveRecordExtension

    set :session, false

    set :root, PurolandGreeting.root

    set :assets_prefix, '/assets'
    set :sprockets, Sprockets::Environment.new

    set :haml, format: :html5, escape_html: true, attr_wrapper: '"'

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

      sprockets.append_path 'bower_components'
      sprockets.append_path 'assets/images'
      sprockets.append_path 'assets/javascripts'
      sprockets.append_path 'assets/stylesheets'
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
      months = Schedule.months
      schedules = Schedule.order('date DESC')
      characters = Character.order('name ASC')
      haml :index, locals: {
        today: today,
        today_schedule: today_schedule,
        months: months,
        schedules: schedules,
        characters: characters,
      }
    end

    get '/export' do
      content_type 'text/ltsv'
      Database.export
    end

    get %r{\A/schedule/(\d{4})/(\d{2})/(\d{2})/\z} do |year, month, day|
      date = Date.new(year.to_i, month.to_i, day.to_i)
      schedule = Schedule.where('date = ?', date).first or not_found
      time = Time.now
      @title = date.strftime('%Y/%m/%d')
      haml :schedule, locals: {
        schedule: schedule,
        before_the_start: schedule.greetings.before_the_start(time),
        in_session: schedule.greetings.in_session(time),
        after_the_end: schedule.greetings.after_the_end(time),
        deleted: schedule.greetings.deleted
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
        appearances = character.greetings.joins(:schedule).where('schedules.date > ?', from).count('DISTINCT schedules.date')
        dates = Schedule.where('date > ?', from).count('DISTINCT date')
        appearance_dates = character.greetings.joins(:schedule).where('schedules.date > ?', from).count
        appearance_probability  = Rational(appearances, dates)
        item.merge(
          appearances: appearances,
          dates: dates,
          appearance_dates: appearance_dates,
          appearance_probability: appearance_probability)
      }

      greetings_by_month = character.greetings.joins(:schedule).order("year, month").group("year, month").select("DATE_PART('year', date) AS year, DATE_PART('month', date) AS month, COUNT(greetings.id) AS count")

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
            [ "#{item.year}/#{item.month}", item.count.to_i, ]
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
