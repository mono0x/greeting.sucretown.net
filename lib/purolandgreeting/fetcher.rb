require 'mechanize'
require 'nkf'

module PurolandGreeting
  class Fetcher
    BASE_URI = 'http://www.puroland.co.jp/chara_gre/mobile/'

    def self.fetch
      agent = Mechanize.new
      agent.user_agent = 'iPhone (Ruby; http://greeting.sucretown.net/)'

      index_page = self.try_request {|i|
        agent.get(BASE_URI)
      }
      if index_page.search('p').any? {|p| p.text.include? '本日のｷｬﾗｸﾀｰ情報は公開されておりません。P' }
        index_page = self.try_request {|i|
          agent.get("#{BASE_URI}?para=#{Date.today.strftime('%Y%m%d')}")
        }
      end
      #index_page = agent.get('http://www.puroland.co.jp/chara_gre/?para=20130627')
      return [] if index_page.forms.empty?

      t = self.normalize_date(index_page.search('p[align="center"] font[size="-1"]').first.text)
      t.match(/^\s*(?<year>\d+)年(?<month>\d+)月(?<day>\d+)日\([日月火水木金土]\)\s*$/) do |m|
        year = Integer(m[:year])
        month = Integer(m[:month])
        day = Integer(m[:day])

        menu_page = self.try_request {|i|
          agent.submit(index_page.forms.first)
        }

        result = []
        menu_page.links_with(:href => /^chara_sche\.asp\?/).each do |link|
          sleep 10

          schedule_page = self.try_request {|i|
            agent.click(link)
          }
          character = link.text
          schedule_page.search('p[align="left"] font[size="-1"]').each do |font|
            next unless font.children.size == 3
            time, br, place = font.children
            next unless br.name == 'br'
            self.normalize_date(time.text).match(/\A\s*(?<start_hour>\d+):(?<start_minute>\d+)-(?<end_hour>\d+):(?<end_minute>\d+)\z/) do |m|
              start_at = Time.local(year, month, day, Integer(m[:start_hour]), Integer(m[:start_minute]))
              end_at = Time.local(year, month, day, Integer(m[:end_hour]), Integer(m[:end_minute]))
              result << { character: character, place: self.normalize_date(place.text), start_at: start_at, end_at: end_at }
            end
          end
          agent.back
        end
        result
      end
    end

    def self.normalize_date(s)
      NKF.nkf '-W1 -Ww -m0Z1', s
    end

    def self.try_request(n = 10, &block)
      n.times do |i|
        begin
          return block.call(i)
        rescue
          sleep [ 2 ** i, 30 ].min
        end
      end
      raise $!
    end
  end
end
