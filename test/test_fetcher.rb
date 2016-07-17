require_relative 'helper'

class TestFetcher < Test::Unit::TestCase
  def test_fetch
    VCR.use_cassette('test_fetch') do
      result = PurolandGreeting::Fetcher.fetch(false)
      assert_equal result[:items].size, 56
      assert_equal result[:nextday_items].size, 23
      assert_equal result[:new_items].size, 56
      assert_equal result[:new_nextday_items].size, 23
    end
  end

  def test_fetch_when_unpublished
    VCR.use_cassette('test_fetch_when_unpublished') do
      result = PurolandGreeting::Fetcher.fetch(false)
      assert_equal result[:items].size, 0
      assert_equal result[:nextday_items].size, 0
      assert_equal result[:new_items].size, 0
      assert_equal result[:new_nextday_items].size, 0
    end
  end
end
