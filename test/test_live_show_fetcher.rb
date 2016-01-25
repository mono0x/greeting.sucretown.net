require_relative 'helper'

class TestLiveShowFetcher < Test::Unit::TestCase
  def test_fetch
    VCR.use_cassette('test_live_show_fetch') do
      items = PurolandGreeting::LiveShowFetcher.fetch
      assert_equal items.size, 12
    end
  end

  def test_fetch_detail
    VCR.use_cassette('test_live_show_fetch_detail') do
      item = PurolandGreeting::LiveShowFetcher.fetch_detail('http://www.puroland.jp/liveshow/little-hero/')
      assert_equal item[:place], 'フェアリーランドシアター'
      assert_equal item[:time], 40
    end
  end
end
