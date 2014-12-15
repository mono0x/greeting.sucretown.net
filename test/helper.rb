if ENV['SIMPLE_COV']
  require 'simplecov'
  SimpleCov.start do
    add_filter '/test/'
  end
end

require 'bundler'
Bundler.require :default, :test
require 'rr'
require 'test/unit'
require 'test/unit/rr'

$:.push File.expand_path('../lib', __dir__)

require 'purolandgreeting'
