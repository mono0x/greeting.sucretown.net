require_relative 'helper'

class TestEventFetcher < Test::Unit::TestCase
  def test_fetch
    VCR.use_cassette('test_event_fetch') do
      items = PurolandGreeting::EventFetcher.fetch
      assert_equal items.size, 20
      assert_equal items[0][:date], Date.new(2015, 12, 15)
      assert_equal items[0][:uri], 'http://www.puroland.jp/information/challenge-mymelody/'
    end
  end
end
