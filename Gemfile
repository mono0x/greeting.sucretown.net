source 'https://rubygems.org'
ruby '2.2.3'

gem 'activerecord'
gem 'activesupport', require: 'active_support/all'
gem 'dotenv'
gem 'dropbox-sdk', require: 'dropbox_sdk'
gem 'escape_utils'
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
gem 'slack-notifier'
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
  gem 'rails-assets-momentjs'
  gem 'rails-assets-underscore'
  gem 'rails-assets-vue'
end

group :schedule do
  gem 'rufus-scheduler', require: 'rufus/scheduler'
end

group :development do
  gem 'guard'
  gem 'guard-rake'
  gem 'sinatra-contrib', require: 'sinatra/reloader'
  gem 'pry'
end

group :test do
  gem 'database_cleaner'
  gem 'factory_girl', '~> 4.0'
  gem 'rack-test', require: 'rack/test'
  gem 'rr', require: false
  gem 'simplecov', require: false
  gem 'test-unit', '~> 3.0', require: false
  gem 'test-unit-rr', require: false
  gem 'timecop'
  gem 'vcr'
  gem 'webmock'
end
