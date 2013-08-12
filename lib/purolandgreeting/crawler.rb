require 'date'

module PurolandGreeting
  class Crawler
    def update
      Database.register Fetcher.fetch
    end
  end
end
