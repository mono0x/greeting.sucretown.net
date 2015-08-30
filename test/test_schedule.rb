require_relative 'helper'

class TestSchedule < Test::Unit::TestCase
  def self.startup
    Timecop.freeze Time.local(2015, 3, 3, 15, 0)
    DatabaseCleaner.start
    FactoryGirl.lint
  end

  def self.shutdown
    DatabaseCleaner.clean
    Timecop.return
  end

  def test_months
    months = PurolandGreeting::Schedule.months
    assert_equal months.size, 2
    assert_equal months[0].year, 2015
    assert_equal months[0].month, 5
    assert_equal months[1].year, 2015
    assert_equal months[1].month, 3
  end

end
