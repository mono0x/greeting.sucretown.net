# -*- coding: utf-8 -*-

module PurolandGreeting
  class CrawlerTask
    def self.register
      self.update true
    end

    def self.update(register = false)
      now = Time.now
      today = Date.today

      added_items, deleted_items, registered = Crawler.update(register)

      twitter = Twitter::REST::Client.new do |config|
        config.consumer_key = ENV['TWITTER_CONSUMER_KEY']
        config.consumer_secret = ENV['TWITTER_CONSUMER_SECRET']
        config.access_token = ENV['TWITTER_ACCESS_TOKEN']
        config.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
      end

      normalizer = Normalizer.new

      uri = "#{ENV['ROOT_URI']}#{today.strftime('/schedule/%Y/%m/%d/')}"

      if registered
        twitter.update "#{today.strftime('%Y/%m/%d')} の予定が公開されました。 #{uri}"

        characters = added_items.map {|item| normalizer.character_full_name item[:character] }.uniq.sort

        header = "#{today.strftime('%Y/%m/%d')} の登場キャラクター"
        self.update_items twitter, characters, header
      else
        unless added_items.empty? && deleted_items.empty?
          time = now.strftime('%H:%M')
          twitter.update "#{today.strftime('%Y/%m/%d')} の予定が変更されました。 (#{time}) #{uri}"

          tables = [ '追加', '中止' ].zip([ added_items, deleted_items ].map {|items|
            items.group_by {|item| normalizer.character_full_name item[:character] }
          })
          characters = tables.map {|t| t[1].keys }.inject(&:|).sort

          header = "#{today.strftime('%Y/%m/%d')} の変更対象キャラクター (#{time})"
          self.update_items twitter, characters.to_a, header

          characters.each do |character|
            tables.each do |title, table|
              header = "#{character} の#{title}分 (#{time})"
              if items = table[character]
                parts = items.map {|item|
                  "#{item[:start_at].strftime('%H:%M')}-#{item[:end_at].strftime('%H:%M')} #{normalizer.place(item[:place])}"
                }
                self.update_items twitter, parts, header
              else
                twitter.update "#{header}:\nなし"
              end
            end
          end
        end
      end
    end

    def self.update_items(twitter, items, header, footer = nil)
      separator = "\n"
      separator_size = separator.size

      header_size = header.size + 8 # "#{header} (n/m): "
      footer_size = footer ? footer.size + 1 : 0 # " #{footer}"

      groups = []
      group = []
      items.each do |item|
        if header_size + footer_size + group.map(&:size).inject(0, &:+) + group.size * separator_size + item.size > 140
          groups << group
          group = [ item ]
        else
          group << item
        end
      end
      groups << group unless group.empty?

      groups.each_with_index do |group, i|
        pager = " (#{i + 1}/#{groups.size})" if groups.size >= 2
        twitter.update [ "#{header}#{pager}:", group, footer ].flatten.compact.join(separator)
      end
    end
  end
end
