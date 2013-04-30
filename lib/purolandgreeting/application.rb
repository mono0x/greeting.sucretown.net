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

    get '/' do
      schedule = Schedule.where('date = ?', Date.today).first or not_found
      haml :index, locals: {
        schedule: schedule,
      }
    end
  end
end
