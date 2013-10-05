require 'date'

module PurolandGreeting
  class Crawler
    def self.register
      self.update true
    end

    def self.update(register = false)
      schedule = Schedule.where('date = ?', Date.today).first
      return [ [], [], false ] if register && schedule
      added_items, deleted_items = Database.register(Fetcher.fetch)
      [ added_items, deleted_items, !schedule && !added_items.empty? ]
    end
  end
end
