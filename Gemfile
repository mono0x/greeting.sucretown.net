
source 'https://rubygems.org'

gem 'rack'
gem 'rack-contrib', :require => 'rack/contrib'
gem 'activerecord', '~> 4.0.2'
gem 'sinatra', :require => 'sinatra/base'
gem 'sinatra-activerecord', :require => 'sinatra/activerecord'
gem 'activesupport', :require => 'active_support/all'
gem 'haml'
gem 'sass'
gem 'compass'
gem 'escape_utils'
gem 'twitter', :github => 'sferik/twitter'
gem 'rake'
gem 'hashie'
gem 'varnish-client', :git => 'https://github.com/mono0x/varnish-client.git'
gem 'coffee-script'
gem 'sprockets', '~> 2.10.0'
gem 'sprockets-sass'
gem 'sprockets-helpers'
gem 'foreman', :github => 'ddollar/foreman'
gem 'mechanize'
gem 'uglifier'
gem 'ltsv'

group :schedule do
  gem 'rufus-scheduler', '~> 2.0.24', :require => 'rufus/scheduler'
  gem 'ruby-gmail', :require => 'gmail', :git => 'https://github.com/dcparker/ruby-gmail'
end

group :development do
  gem 'sqlite3'
  gem 'guard', :require => false
  gem 'guard-bundler', :require => false
  gem 'guard-pow', :require => false
  gem 'guard-rspec', :require => false
  gem 'rb-inotify', :require => false
  gem 'rb-fsevent', :require => false
  gem 'ruby_gntp', :require => false
  gem 'pry'

  group :test do
    gem 'rspec'
    gem 'rack-test', :require => 'rack/test'
    gem 'simplecov'
    gem 'factory_girl'
  end
end

group :production do
  gem 'pg'
  gem 'unicorn'
end

