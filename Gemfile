source 'https://rubygems.org'
ruby '2.6.1'

git 'https://github.com/rails/rails', branch: '5-0-stable' do
  gem 'activerecord'
  gem 'activesupport', require: 'active_support/all'
end
gem 'dotenv', require: false
gem 'dropbox_api'
gem 'escape_utils'
gem 'foreman', require: false
gem 'hamlit'
gem 'hashie'
gem 'ltsv'
gem 'mechanize'
gem 'octokit', '~> 4.0'
gem 'pg'
gem 'pry', require: false
gem 'rack'
gem 'rack-contrib', require: 'rack/contrib'
gem 'rack-timeout'
gem 'rake', require: false
gem 'ridgepole'
gem 'server-starter'
gem 'sinatra', require: 'sinatra/base'
gem 'slack-notifier'
gem 'twitter'
gem 'unicorn'
gem 'unicorn-worker-killer', require: false

group :development do
  gem 'guard'
  gem 'guard-rake'
  gem 'sinatra-contrib', require: 'sinatra/reloader'
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
