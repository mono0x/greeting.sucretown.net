require 'date'
require 'mechanize'
require 'nkf'

module PurolandGreeting
  class Fetcher
    BASE_URI = 'http://www.puroland.co.jp/chara_gre/mobile/'
    INTERVAL = 0.5

    def self.fetch(wait = true)
      self.new.fetch wait
    end

    def create_agent
      agent = Mechanize.new
      agent.user_agent = 'iPhone (Ruby; http://greeting.sucretown.net/)'
      agent
    end

    def fetch(wait = true)
      agent = create_agent

      index_page = try_request {
        agent.get(BASE_URI)
      }
      if index_page.search('p').any? {|p| p.text.include? '本日のｷｬﾗｸﾀｰ情報は公開されておりません。P' }
        index_page = try_request {
          agent.get("#{BASE_URI}?para=#{Date.today.strftime('%Y%m%d')}")
        }
      end
      #index_page = agent.get('http://www.puroland.co.jp/chara_gre/?para=20130627')
      return [] if index_page.forms.empty?

      date = parse_date(index_page) or return []

      menu_page = try_request {
        agent.submit(index_page.forms.first)
      }

      result = []
      menu_page.links_with(:href => /^chara_sche\.asp\?/).each do |link|
        sleep INTERVAL if wait

        schedule_page = try_request {
          agent.click(link)
        }
        character = link.text
        schedule_page.search('p[align="left"] font[size="-1"]').each do |font|
          next unless font.children.size == 3
          time, br, place = font.children
          next unless br.name == 'br'
          normalize_string(time.text).match(/\A\s*(?<start_hour>\d+):(?<start_minute>\d+)-(?<end_hour>\d+):(?<end_minute>\d+)\z/) do |m|
            start_at = Time.local(date.year, date.month, date.day, Integer(m[:start_hour]), Integer(m[:start_minute]))
            end_at = Time.local(date.year, date.month, date.day, Integer(m[:end_hour]), Integer(m[:end_minute]))
            result << { character: character, place: normalize_string(place.text), start_at: start_at, end_at: end_at }
          end
        end
        agent.back
      end
      result
    end

    def parse_date(index_page)
      t = normalize_string(index_page.search('p[align="center"] font[size="-1"]').first.text)
      t.match(/(?<year>\d+)年(?<month>\d+)月(?<day>\d+)日\([日月火水木金土]\)\s*/) do |m|
        return Date.new(Integer(m[:year]), Integer(m[:month]), Integer(m[:day]))
      end
      nil
    end

    def normalize_string(s)
      NKF.nkf '-W1 -Ww -m0Z1', s
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
