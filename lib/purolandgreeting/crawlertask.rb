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

        characters = added_items.map {|item| normalizer.character(item[:character])[0] }.uniq.sort

        header = "#{today.strftime('%Y/%m/%d')} の登場キャラクター"
        self.update_characters twitter, characters, header
      else
        unless added_items.empty? && deleted_items.empty?
          twitter.update "#{today.strftime('%Y/%m/%d')} の予定が変更されました。 (#{now.strftime('%H:%M')}) #{uri}"

          added_characters = SortedSet.new(added_items.map {|item| normalizer.character(item[:character])[0] })
          deleted_characters = SortedSet.new(deleted_items.map {|item| normalizer.character(item[:character])[0] })
          modified_characters = added_characters & deleted_characters
          added_characters -= modified_characters
          deleted_characters -= modified_characters

          [ '追加', '変更', '中止' ].zip([ added_characters, modified_characters, deleted_characters ]).each do |title, characters|
            next if characters.empty?
            header = "#{today.strftime('%Y/%m/%d')} の#{title}対象キャラクター (#{now.strftime('%H:%M')})"
            self.update_characters twitter, characters, header
          end
        end
      end
    end

    def self.update_characters(twitter, characters, header, footer = nil)
      separator = ' '
      separator_size = separator.size

      header_size = header.size + 8 # "#{header} (n/m): "
      footer_size = footer ? footer.size + 1 : 0 # " #{footer}"

      groups = []
      group = []
      characters.each do |character|
        if header_size + footer_size + group.map(&:size).inject(0, &:+) + group.size * separator_size + character.size > 140
          groups << group
          group = [ character ]
        else
          group << character
        end
      end
      groups << group unless group.empty?

      groups.each_with_index do |group, i|
        twitter.update [ header, "(#{i + 1}/#{groups.size}): #{group.join(separator)}", footer ].compact.join(' ')
      end
    end
  end
end
