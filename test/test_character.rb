require_relative 'helper'

class TestCharacter < Test::Unit::TestCase
  def self.startup
    Timecop.freeze Time.local(2015, 3, 6, 15, 0)
    DatabaseCleaner.start
  end

  def self.shutdown
    DatabaseCleaner.clean
    Timecop.return
  end

end
