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

  def test_count_dates
    date_from = Date.new(2015, 1, 1)
    assert_equal PurolandGreeting::Schedule.count_dates(date_from), 3
  end

  def test_next_schedule
    schedule = PurolandGreeting::Schedule.where('date = ?', Date.new(2015, 3, 6)).first
    assert_equal schedule.next_schedule.date, Date.new(2015, 3, 7)

    schedule = PurolandGreeting::Schedule.where('date = ?', Date.new(2015, 5, 5)).first
    assert_equal schedule.next_schedule, nil
  end

  def test_prev_schedule
    schedule = PurolandGreeting::Schedule.where('date = ?', Date.new(2015, 3, 6)).first
    assert_equal schedule.prev_schedule, nil

    schedule = PurolandGreeting::Schedule.where('date = ?', Date.new(2015, 5, 5)).first
    assert_equal schedule.prev_schedule.date, Date.new(2015, 3, 7)
  end
end
