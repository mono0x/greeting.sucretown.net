require 'bundler'
Bundler.require
require 'sinatra/activerecord/rake'
require 'tmpdir'

$:.push File.expand_path('lib', __dir__)

require 'purolandgreeting'

namespace :crawler do
  task :register do
    PurolandGreeting::CrawlerTask.register
  end

  task :update do
    PurolandGreeting::CrawlerTask.update
  end
end

namespace :db do
  task :import do
    PurolandGreeting::Database.import STDIN
  end

  task :import_ohtake_csv do
    PurolandGreeting::Database.import_ohtake_csv STDIN
  end

  task :export do
    STDOUT.puts PurolandGreeting::Database.export
  end

  task :normalize do
    PurolandGreeting::Database.normalize
  end
end

namespace :backup do
  task :setup do
    flow = DropboxOAuth2FlowNoRedirect.new(ENV['DROPBOX_CONSUMER_KEY'], ENV['DROPBOX_CONSUMER_SECRET'])
    authorize_url = flow.start()

    # Have the user sign in and authorize this app
    STDERR.puts '1. Go to: ' + authorize_url
    STDERR.puts '2. Click "Allow" (you might have to log in first)'
    STDERR.puts '3. Copy the authorization code'
    STDERR.print 'Enter the authorization code here: '
    code = STDIN.gets.strip

    # This will fail if the user gave us an invalid authorization code
    access_token, user_id = flow.finish(code)
    puts access_token
  end

  task :run do
    Dir.mktmpdir do |dir|
      sql = File.join(dir, 'database.sql')
      ltsv = File.join(dir, 'database.ltsv')

      dropbox_dir = '/work/greeting.sucretown.net/data'

      system "pg_dump --inserts -x -h localhost -U greeting puroland-greeting | xz > #{sql}.xz"
      open(ltsv, 'w') do |f|
        f << PurolandGreeting::Database.export
      end
      system "xz #{ltsv}"

      dropbox = DropboxClient.new(ENV['DROPBOX_ACCESS_TOKEN'])
      open("#{sql}.xz") do |f|
        dropbox.put_file File.join(dropbox_dir, 'database.sql.xz'), f, true
      end
      open("#{ltsv}.xz") do |f|
        dropbox.put_file File.join(dropbox_dir, 'database.ltsv.xz'), f, true
      end
    end
  end
end
