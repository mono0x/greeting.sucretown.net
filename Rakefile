require 'bundler'
Bundler.require
require 'sinatra/activerecord/rake'

$:.push File.expand_path('lib', __dir__)

require 'purolandgreeting'

namespace :crawler do
  task :update do
    PurolandGreeting::Crawler.new.update
  end
end
