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

Dotenv.overload '.env.test'

$:.push File.expand_path('../lib', __dir__)

require 'purolandgreeting'

VCR.configure do |config|
  config.cassette_library_dir = 'test/fixtures/vcr_cassettes'
  config.hook_into :webmock
end

FactoryGirl.find_definitions
class Test::Unit::TestCase
  include FactoryGirl::Syntax::Methods
end

system 'rake db:schema:apply'
DatabaseCleaner.clean_with :truncation
DatabaseCleaner.strategy = :transaction
