require 'date'

module PurolandGreeting
  class Crawler
    def self.register
      Database.register Fetcher.fetch unless Schedule.where('date = ?', Date.today).first
    end

    def self.update
      Database.register Fetcher.fetch
    end
  end
end
