require 'date'
require 'json'
require 'open-uri'

module PurolandGreeting
  class EventFetcher
    API_ENDPOINT_URI = 'http://www.puroland.jp/api/live/get_information/?category=event&page=1&count=20'

    def self.fetch
      self.new.fetch
    end

    def fetch
      data = try_request {
        JSON.parse(open(API_ENDPOINT_URI).read)
      }

      items = []
      data['data'].each {|item|
        public_date = Date.new(*item['public_date'].split('/').map {|i| i.to_i(10) })

        m = item['title'].match(%r!\A(?:【(?<month>\d{1,2})/(?<day>\d{1,2}).+?】)?(?<title>.+)\z!)
        date = if m && m[:month]
          month = m[:month].to_i(10)
          day = m[:day].to_i(10)
          if public_date.month > month || (public_date.month == month && public_date.day >= day)
            Date.new(public_date.year + 1, month, day)
          else
            Date.new(public_date.year, month, day)
          end
        else
          public_date
        end

        items << {
          date: date,
          title: m[:title],
          uri: item['url'],
          updated_on: item['public_date'],
          thumbnail_s: item['thumbnail_s'],
          thumbnail_m: item['thumbnail_m'],
        }
      }

      items.sort_by {|item| item[:date] }
    end


    private

    def try_request(n = 10, &block)
      delays = (0...n).map {|i| [ 2 ** i, 30 ].min }
      begin
        return block.call
      rescue
        if delay = delays.shift
          sleep delay
          retry
        else
          raise
        end
      end
    end
  end
end
