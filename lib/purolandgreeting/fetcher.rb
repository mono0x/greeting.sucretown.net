require 'mechanize'
require 'nkf'

module PurolandGreeting
  class Fetcher
    def self.fetch
      agent = Mechanize.new
      agent.user_agent_alias = 'iPhone'

      index_page = agent.get('http://www.puroland.co.jp/chara_gre/')
      return [] if index_page.forms.empty?

      m = index_page.search('p[align="center"] font[size="-1"]').first.text.match(/\A\s*(\d+)年(\d+)月(\d+)日\([日月火水木金土]\)\s*\z/) or exit
      year = Integer(m[1])
      month = Integer(m[2])
      day = Integer(m[3])

      menu_page = agent.submit(index_page.forms.first)

      result = []
      menu_page.links_with(:href => /^chara_sche\.asp\?/).each do |link|
        schedule_page = agent.click(link)
        character = link.text
        schedule_page.search('p[align="left"] font[size="-1"]').each do |font|
          m = font.text.match(/\A\s*(\d+):(\d+)-(\d+):(\d+)\s*(.+)\s*\z/) or next
          start_at = Time.local(year, month, day, Integer(m[1]), Integer(m[2]))
          end_at = Time.local(year, month, day, Integer(m[3]), Integer(m[4]))
          place = NKF.nkf('-W1 -Ww', m[5])
          result << { character: character, place: place, start_at: start_at, end_at: end_at }
        end
        agent.back
      end
      result
    end
  end
end
