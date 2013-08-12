require 'mechanize'

module PurolandGreeting
  class Fetcher
    def self.fetch
      agent = Mechanize.new
      agent.user_agent_alias = 'iPhone'

      index_page = agent.get('http://www.puroland.co.jp/chara_gre/')
      #index_page = agent.get('http://www.puroland.co.jp/chara_gre/?para=20130627')
      return [] if index_page.forms.empty?

      t = index_page.search('p[align="center"] font[size="-1"]').first.text
      t.match(/\A\s*(?<year>\d+)年(?<month>\d+)月(?<day>\d+)日\([日月火水木金土]\)\s*\z/) do |m|
        year = Integer(m[:year])
        month = Integer(m[:month])
        day = Integer(m[:day])

        menu_page = agent.submit(index_page.forms.first)

        result = []
        menu_page.links_with(:href => /^chara_sche\.asp\?/).each do |link|
          schedule_page = agent.click(link)
          character = link.text
          schedule_page.search('p[align="left"] font[size="-1"]').each do |font|
            font.text.match(/\A\s*(?<start_hour>\d+):(?<start_minute>\d+)-(?<end_hour>\d+):(?<end_minute>\d+)\s*(?<place>.+)\s*\z/) do |m|
              start_at = Time.local(year, month, day, Integer(m[:start_hour]), Integer(m[:start_minute]))
              end_at = Time.local(year, month, day, Integer(m[:end_hour]), Integer(m[:end_minute]))
              result << { character: character, place: m[:place], start_at: start_at, end_at: end_at }
            end
          end
          agent.back
        end
        result
      end
    end
  end
end
