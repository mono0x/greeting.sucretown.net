require 'date'
require 'mechanize'
require 'nkf'

module PurolandGreeting
  class Fetcher
    OLD_INDEX_URI = 'http://www.puroland.co.jp/chara_gre/mobile/'
    NEW_INDEX_URI = 'http://www.puroland.jp/schedule/greeting/'
    OLD_NEXTDAY_URI = 'http://www.puroland.co.jp/chara_gre/chara_sentaku_nextday.asp'
    NEW_NEXTDAY_URI = 'http://www.puroland.jp/schedule/greeting/'
    INTERVAL = 0.5

    def self.fetch(wait = true)
      self.new.fetch wait
    end

    def create_agent
      agent = Mechanize.new
      agent.user_agent = 'iPhone (Ruby; https://greeting.sucretown.net/)'
      agent
    end

    def fetch(wait = true)
      agent = create_agent

      old_index_page = try_request {
        agent.get(OLD_INDEX_URI)
      }
      if old_index_page.search('p').any? {|p| p.text.include? '本日のｷｬﾗｸﾀｰ情報は公開されておりません。P' }
        old_index_page = try_request {
          agent.get("#{OLD_INDEX_URI}?para=#{Date.today.strftime('%Y%m%d')}")
        }
      end
      #old_index_page = agent.get('http://www.puroland.co.jp/chara_gre/?para=20130627')
      return {} if old_index_page.forms.empty?

      date = parse_date(normalize_string(old_index_page.search('p[align="center"] font[size="-1"]').first.text)) or return {}

      menu_page = try_request {
        agent.submit(old_index_page.forms.first)
      }
      items = []
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
            items << { character: character, place: normalize_string(place.text), start_at: start_at, end_at: end_at }
          end
        end
        agent.back
      end

      new_index_page = try_request {
        agent.get(NEW_INDEX_URI)
      }
      new_items = []
      new_index_page.search('.characterList li').each do |li|
        uri = li.search('a').attr('href')
        next unless uri

        character = li.search('.charaName').text
        next if character.empty?

        sleep INTERVAL if wait

        schedule_page = try_request {
          agent.get(uri)
        }
        schedule_page.search('.subColorBG .itemDetailBox').each do |box|
          place = normalize_string(box.search('.itemTitle').text)
          box.search('.itemContent dd').text.split("～").each do |t|
            t.strip.match(%r{(?<hour>\d+):(?<minute>\d+)}) do |m|
              start_at = Time.local(date.year, date.month, date.day, Integer(m[:hour]), Integer(m[:minute]))
              end_at = nil
              new_items << { character: character, place: place, start_at: start_at, end_at: end_at, }
            end
          end
        end
      end

      tchk = menu_page.uri.to_s.match(/TCHK=(\d+)/).to_a[1]
      nextday_page = try_request {
        agent.get("#{OLD_NEXTDAY_URI}?TCHK=#{tchk}")
      }
      nextday = parse_date(nextday_page.search('.newsTop3').first.text)
      nextday_items = []
      nextday_page.search('#newsWrap2 table tr:nth-child(2n) td').each do |td|
        next if td.text.empty?
        nextday_items << { character: td.text, date: nextday }
      end

      new_nextday_page = try_request {
        agent.get("#{NEW_NEXTDAY_URI}?date=#{nextday.strftime('%Y%m%d')}")
      }
      new_nextday_items = []
      new_nextday_page.search('.characterList li .charaName').each do |name|
        next if name.text.empty?
        new_nextday_items << { character: name.text, date: nextday }
      end

      {
        items: items,
        new_items: new_items,
        nextday_items: nextday_items,
        new_nextday_items: new_nextday_items,
      }
    end

    def parse_date(t)
      t.match(/(?<year>\d+)年(?<month>\d+)月(?<day>\d+)日(?:\([日月火水木金土]\))?\s*/) do |m|
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
