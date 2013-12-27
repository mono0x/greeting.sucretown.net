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

  task :backup do
    Dir.mktmpdir do |dir|
      sql = File.join(dir, 'database.sql')
      ltsv = File.join(dir, 'database.ltsv')

      dropbox_dir = 'dropbox:/work/greeting.sucretown.net/data'

      system "pg_dump --inserts -x -h localhost -U puro puroland-greeting | xz > #{sql}.xz"
      open(ltsv, 'w') do |f|
        f << PurolandGreeting::Database.export
      end
      system "xz #{ltsv}"
      system "dropbox-api put #{sql}.xz #{File.join(dropbox_dir, 'database.sql.xz')}"
      system "dropbox-api put #{ltsv}.xz #{File.join(dropbox_dir, 'database.ltsv.xz')}"
    end
  end
end
