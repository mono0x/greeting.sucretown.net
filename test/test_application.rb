require_relative 'helper'

class TestApplication < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    PurolandGreeting::Application.new
  end
end
