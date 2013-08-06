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

      sprockets.append_path 'assets/images'
      sprockets.append_path 'assets/javascripts'
      sprockets.append_path 'assets/stylesheets'
    end

    helpers Sprockets::Helpers

    helpers do
      def calendar(month, &block)
        next_month = month >> 1
        days = [ nil ] * month.wday + (1..(next_month - month)).to_a + [ nil ] * ((7 - next_month.wday) % 7)

        haml :'_partial/calendar', layout: false, locals: {
          month: month,
          days: days,
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
      content_type 'text/csv'
      Appearance.order('greeting_id ASC, character_id ASC').map {|a|
        [
          a.character.name,
          a.greeting.place.name,
          a.greeting.start_at,
          a.greeting.end_at,
        ].join(',')
      }.join("\n")
    end

    get %r{\A/schedule/(\d{4})/(\d{2})/(\d{2})/\z} do |year, month, day|
      date = Date.new(year.to_i, month.to_i, day.to_i)
      schedule = Schedule.where('date = ?', date).first or not_found
      time = Time.now
      haml :schedule, locals: {
        schedule: schedule,
        before_the_start: schedule.greetings.before_the_start(time),
        in_session: schedule.greetings.in_session(time),
        after_the_end: schedule.greetings.after_the_end(time),
      }
    end

    get %r{\A/character/([^/]+)/\z} do |name|
      character = Character.where('name = ?', name).first or not_found
      haml :character, locals: {
        character: character,
      }
    end

  end
end
