require_relative 'helper'
require 'uri'

class TestApplication < Test::Unit::TestCase
  include Rack::Test::Methods

  def self.startup
    Timecop.freeze Time.local(2015, 3, 3, 15, 0)
    DatabaseCleaner.start
    VCR.use_cassette('test_fetch') do
      PurolandGreeting::Crawler.register
    end
  end

  def self.shutdown
    DatabaseCleaner.clean
    Timecop.return
  end

  def app
    PurolandGreeting::Application.new
  end

  def test_index
    get '/'
    assert last_response.ok?
    assert last_response.body.include?('2015/03/03 の予定')
    assert !last_response.body.include?('2015/03/03 の予定は公開されていません')
    assert last_response.body.include?('2015/03/04 の登場キャラクター')

    Timecop.freeze Time.local(2015, 3, 4, 15, 0) do
      get '/'
      assert last_response.ok?
      assert last_response.body.include?('2015/03/04 の予定は公開されていません')
      assert !last_response.body.include?('2015/03/05 の登場キャラクター')
    end
  end

  def test_today
    get '/schedule/today'
    assert last_response.redirect?
    assert_equal last_response.location, "#{ENV['ROOT_URI']}/schedule/2015/03/03/"

    Timecop.freeze Time.local(2015, 3, 4, 15, 0) do
      get '/schedule/today'
      assert last_response.redirect?
      assert_equal last_response.location, "#{ENV['ROOT_URI']}/"
    end
  end

  def test_export
    get '/export'
    assert last_response.ok?
  end

  def test_schedules
    get '/schedule/'
    assert last_response.ok?
  end

  def test_schedule
    get '/schedule/2015/03/03/'
    assert last_response.ok?

    get '/schedule/2015/03/04/'
    assert_equal last_response.status, 404
  end

  def test_schedule_characters
    get '/schedule/2015/03/03/character'
    assert_equal last_response.status, 404

    get '/schedule/2015/03/04/character'
    assert last_response.ok?
  end

  def test_characters
    get '/character/'
    assert last_response.ok?
  end

  def test_character
    get "/character/#{URI.encode_www_form_component 'シナモン'}/"
    assert last_response.ok?
  end

  def test_statistics
    get '/statistics/'
    assert last_response.ok?
  end
end
