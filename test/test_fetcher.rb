require_relative 'helper'

class TestFetcher < Test::Unit::TestCase
  def test_fetch
    VCR.use_cassette('test_fetch') do
      result = PurolandGreeting::Fetcher.fetch(false)
      assert_equal result.size, 76
    end
  end

  def test_fetch_when_unpublished
    VCR.use_cassette('test_fetch_when_unpublished') do
      result = PurolandGreeting::Fetcher.fetch(false)
      assert_equal result.size, 0
    end
  end
end
