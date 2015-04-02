source 'https://rubygems.org'
ruby '2.2.1'

gem 'activerecord', '~> 4.0.2'
gem 'activesupport', require: 'active_support/all'
gem 'coffee-script'
gem 'dotenv'
gem 'dropbox-sdk', require: 'dropbox_sdk'
gem 'escape_utils'
gem 'foreigner'
gem 'foreman'
gem 'gctools'
gem 'hamlit'
gem 'hashie'
gem 'ltsv'
gem 'mechanize'
gem 'pg'
gem 'rack'
gem 'rack-contrib', require: 'rack/contrib'
gem 'rack-timeout'
gem 'rake'
gem 'ridgepole'
gem 'sass'
gem 'sinatra', require: 'sinatra/base'
gem 'sprockets', '~> 2.10.0'
gem 'sprockets-helpers'
gem 'sprockets-sass'
gem 'twitter'
gem 'uglifier'
gem 'unicorn'
gem 'unicorn-worker-killer', require: false
gem 'varnish-client', github: 'mono0x/varnish-client'

source 'https://rails-assets.org' do
  gem 'rails-assets-bootswatch'
  gem 'rails-assets-jquery'
  gem 'rails-assets-jquery.scrollTo'
end

group :schedule do
  gem 'gmail'
  gem 'rufus-scheduler', require: 'rufus/scheduler'
end

group :development do
  gem 'guard'
  gem 'guard-rake'
  gem 'sinatra-contrib', require: 'sinatra/reloader'
  gem 'pry'
end

group :test do
  gem 'factory_girl'
  gem 'rack-test', require: 'rack/test'
  gem 'rr', require: false
  gem 'simplecov', require: false
  gem 'test-unit', '~> 3.0', require: false
  gem 'test-unit-rr', require: false
  gem 'vcr'
  gem 'webmock'
end
