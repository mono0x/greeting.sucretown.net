require_relative 'helper'

class TestLiveShowFetcher < Test::Unit::TestCase
  def test_fetch
    VCR.use_cassette('test_live_show_fetch') do
      items = PurolandGreeting::LiveShowFetcher.fetch
      assert_equal items.size, 12
    end
  end
end
