require_relative 'helper'

class TestLiveShowFetcher < Test::Unit::TestCase
  def test_fetch
    VCR.use_cassette('test_live_show_fetch') do
      items = PurolandGreeting::LiveShowFetcher.fetch
      assert_equal items.size, 12
      assert_equal items[0][:title], 'ちっちゃな英雄(ヒーロー)'
      assert_equal items[0][:start_at], Time.new(2016, 1, 27, 10, 25)
      assert_equal items[0][:uri], 'http://www.puroland.jp/liveshow/little-hero/'
      assert_equal items[0][:place], 'フェアリーランドシアター'
      assert_equal items[0][:time], 40
    end
  end
end
