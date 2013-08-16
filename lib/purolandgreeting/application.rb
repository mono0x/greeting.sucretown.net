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
      haml :schedule, locals: {
        schedule: schedule,
        before_the_start: schedule.greetings.without_deleted.before_the_start(time),
        in_session: schedule.greetings.without_deleted.in_session(time),
        after_the_end: schedule.greetings.without_deleted.after_the_end(time),
        deleted: schedule.greetings.only_deleted
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
