require 'set'

module PurolandGreeting
  class Application < Sinatra::Base
    set :session, false

    set :root, PurolandGreeting.root

    set :haml, format: :html5, attr_quote: '"'

    configure :development do
      Bundler.require :development
      register Sinatra::Reloader
      also_reload './lib/**/*.rb'
    end

    configure do
      Database.connect
    end

    helpers do
      def calendar(month, caption: nil, &block)
        next_month = month >> 1
        days = [ nil ] * month.wday + (1..(next_month - month)).to_a + [ nil ] * ((7 - next_month.wday) % 7)
        workdays = Schedule.where('date >= ? AND date < ?', month, next_month).pluck(:date).to_set
        first = Schedule.order('date ASC').first.date
        last = Schedule.order('date ASC').last.date

        haml :'_partial/calendar', layout: false, locals: {
          caption: caption,
          month: month,
          days: days,
          workdays: workdays,
          first: first,
          last: last,
          block: block,
        }
      end

      def number_with_delimiter(i)
        i.to_s.sub(/\A([\-\+])?(\d*)(\.\d+)?\z/) {
          sign = $1
          int = $2
          real = $3
          "#{sign}#{int.reverse.gsub(/(\d{3})(?=\d)/, '\1,').reverse}#{real}"
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

    get '/export' do
      content_type 'text/ltsv'
      Database.export
    end

    get '/schedule/today' do
      date = Date.today
      schedule = Schedule.where('date = ?', date).first
      if schedule
        redirect "#{ENV['ROOT_URI']}#{date.strftime('/schedule/%Y/%m/%d/')}"
      else
        redirect "#{ENV['ROOT_URI']}/"
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

    get %r{\A/api/schedule/(\d{4})/(\d{2})/(\d{2})/\z} do |year, month, day|
      date = Date.new(year.to_i, month.to_i, day.to_i)
      schedule = Schedule.where('date = ?', date).first or not_found
      greetings = schedule.greetings.all.eager_load(:place, :characters)

      greetings.to_json(only: [ :id, :start_at, :end_at, ], include: {
        place: { only: [ :id, :name, ] },
        characters: { only: [ :id, :name, ] },
      })
    end

    get %r{\A/schedule/(\d{4})/(\d{2})/(\d{2})/\z} do |year, month, day|
      date = Date.new(year.to_i, month.to_i, day.to_i)
      schedule = Schedule.where('date = ?', date).first or not_found
      characters = schedule.characters.uniq
      greetings = schedule.greetings.all.eager_load(:place, :characters)

      @title = "#{date.strftime('%Y/%m/%d')} の予定"
      @canonical = "#{ENV['ROOT_URI']}#{date.strftime('/schedule/%Y/%m/%d/')}"
      @description = "登場キャラクター: #{characters.map(&:name).join(' ')}"
      haml :schedule, locals: {
        is_today: schedule.date == Date.today,
        schedule: schedule,
        greetings: greetings.to_json(only: [ :id, :start_at, :end_at, ], include: {
          place: { only: [ :id, :name, ] },
          characters: { only: [ :id, :name, ] },
        }),
      }
    end

    get %r{\A/schedule/(\d{4})/(\d{2})/(\d{2})/character\z} do |year, month, day|
      date = Date.new(year.to_i, month.to_i, day.to_i)
      temporary_schedule = TemporarySchedule.find_by_date(date) or not_found
      today_schedule = Schedule.find_by_date(date)
      characters = temporary_schedule.characters.where('temporary_appearances.deleted = false')
      deleted_characters = temporary_schedule.characters.where('temporary_appearances.deleted = true')
      @title = "#{date.strftime('%Y/%m/%d')} の登場キャラクター"
      @description = "登場キャラクター: #{characters.map(&:name).join(' ')}"
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

        dates = Schedule.count_dates(from)
        appearances = Character.count_appeparances(character.id, from)
        appearance_dates = Character.count_appeparance_dates(character.id, from)

        appearance_probability = dates > 0 ? Rational(appearance_dates, dates) : 0
        Hashie::Mash.new(item.merge(
          appearances: appearances,
          dates: dates,
          appearance_dates: appearance_dates,
          appearance_probability: appearance_probability
        ))
      }

      greetings_by_month = Character.count_greetings_by_month(character.id)

      places = Character.count_appeparances_by_place(character.id)

      @title = character.name
      haml :character, locals: {
        today: today,
        character: character,
        timespans: timespans,
        greetings_by_month: greetings_by_month,
        places: places,
      }
    end

    get '/statistics/' do
      count_by_month = Appearance.count_by_month
      ranking = Greeting.ranking

      @title = '統計'
      haml :statistics, locals: {
        count_by_month: count_by_month,
        ranking: ranking,
      }
    end

  end
end
