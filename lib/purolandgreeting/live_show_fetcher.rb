require 'date'
require 'mechanize'

module PurolandGreeting
  class LiveShowFetcher
    BASE_URI = 'http://www.puroland.jp/'

    def self.fetch
      self.new.fetch
    end

    def create_agent
      agent = Mechanize.new
      agent.user_agent = 'iPhone (Ruby; https://greeting.sucretown.net/)'
      agent
    end

    def fetch
      agent = create_agent

      index_page = try_request {
        agent.get(BASE_URI)
      }

      date = Date.strptime(index_page.search('.tabBnrBlock ul li.yesterday a').attr('href').value.match(/date=(\d{8})/).to_a[1], '%Y%m%d')

      items = []
      details = {}
      index_page.search('.todaysList .todaysItemBox').each do |item|
        title = item.search('.todaysItemTitle').text
        time = item.search('dl.start dd').text
        next if time.empty?
        m = time.match(/\A(?<hour>\d{2}):(?<minute>\d{2})\z/)
        start_at = date.to_time + (m[:hour].to_i(10) * 60 + m[:minute].to_i(10)) * 60

        uri = item.search('.itemDetailBtn a.basicBtn').attr('href').value
        detail = (details[uri] ||= fetch_detail(uri))
        if start_at
          items << {
            title: title,
            start_at: start_at,
            uri: uri,
            place: detail[:place],
            time: detail[:time],
          }
        end
      end

      items
    end

    private

    def fetch_detail(uri)
      agent = create_agent

      detail_page = try_request {
        agent.get(uri)
      }

      tr = detail_page.search('.basicInfoBlock .basicTable table tr').to_a
      place = tr[1].search('td').text
      m = tr[3].search('td').text.match(/約(?<time>\d+)分/)

      {
        place: place,
        time: m[:time].to_i(10),
      }
    end

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
