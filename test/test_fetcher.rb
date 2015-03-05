require_relative 'helper'

class TestFetcher < Test::Unit::TestCase
  def test_fetch
    VCR.use_cassette('test_fetch') do
      items, nextday_items = *PurolandGreeting::Fetcher.fetch(false)
      assert_equal items.size, 33
      assert_equal nextday_items.size, 18
    end
  end

  def test_fetch_when_unpublished
    VCR.use_cassette('test_fetch_when_unpublished') do
      items, nextday_items = *PurolandGreeting::Fetcher.fetch(false)
      assert_equal items.size, 0
      assert_equal nextday_items.size, 0
    end
  end
end
