module PurolandGreeting
  class Application < Sinatra::Base
    register Sinatra::ActiveRecordExtension

    set :session, false

    set :root, PurolandGreeting.root

    set :assets_prefix, '/assets'
    set :sprockets, Sprockets::Environment.new

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

    get '/' do
      schedules = Schedule.order('date DESC')
      haml :index, locals: {
        schedules: schedules,
      }
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

  end
end
