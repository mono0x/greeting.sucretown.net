require 'bundler'
Bundler.require
require 'pry'
require 'tempfile'
require 'tmpdir'
require 'uri'
require 'yaml'
require 'rake/testtask'

$:.push File.expand_path('lib', __dir__)

Rake::TestTask.new do |t|
  Dotenv.load '.env.test'
  t.libs << 'test'
  t.test_files = Dir['test/**/test_*.rb'].sort
  t.verbose = true
end

task :coverage do |t|
  ENV['SIMPLE_COV'] = '1'
  Rake::Task['test'].invoke
end

task :console do |t|
  require 'purolandgreeting'
  TOPLEVEL_BINDING.eval 'include PurolandGreeting'
  Pry.start
end

task :server do |t|
  exec "unicorn -c unicorn.conf -E #{ENV['RACK_ENV']} -p #{ENV['PORT']}"
end

namespace :crawler do
  task :register do
    require 'purolandgreeting'
    PurolandGreeting::CrawlerTask.register
  end

  task :update do
    require 'purolandgreeting'
    PurolandGreeting::CrawlerTask.update
  end
end

namespace :db do
  task :import do
    require 'purolandgreeting'
    PurolandGreeting::Database.import STDIN
  end

  task :import_ohtake_csv do
    require 'purolandgreeting'
    PurolandGreeting::Database.import_ohtake_csv STDIN
  end

  task :export do
    require 'purolandgreeting'
    STDOUT.puts PurolandGreeting::Database.export
  end

  task :normalize do
    require 'purolandgreeting'
    PurolandGreeting::Database.normalize
  end

  namespace :schema do
    require 'ridgepoleraketask'
    RidgepoleRakeTask.new do |t|
      t.database_uri = ENV['DATABASE_URL']
    end
  end
end

namespace :backup do
  require 'dropboxraketask'
  DropboxRakeTask.new

  task :run do
    require 'purolandgreeting'
    Dir.mktmpdir do |dir|
      sql = File.join(dir, 'database.sql')
      ltsv = File.join(dir, 'database.ltsv')

      dropbox_dir = '/work/greeting.sucretown.net/data'
      database_url = URI.parse(ENV['DATABASE_URL'])

      system "pg_dump --inserts -x -h #{database_url.host} -U #{database_url.user} #{database_url.path.delete('/')} | xz > #{sql}.xz"
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

namespace :varnish do
  task :purge do
    require 'purolandgreeting'
    PurolandGreeting::VarnishCachePurger.new.run if ENV['VARNISH_URL']
  end
end
