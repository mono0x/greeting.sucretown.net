# -*- coding: utf-8 -*-

module PurolandGreeting
  class CrawlerTask
    def self.register
      self.update true
    end

    def self.update(register = false)
      added_items, deleted_items, registered = Crawler.update(register)

      twitter = Twitter::REST::Client.new do |config|
        config.consumer_key = ENV['TWITTER_CONSUMER_KEY']
        config.consumer_secret = ENV['TWITTER_CONSUMER_SECRET']
        config.access_token = ENV['TWITTER_ACCESS_TOKEN']
        config.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
      end

      normalizer = Normalizer.new

      today = Date.today
      uri = "#{ENV['ROOT_URI']}#{today.strftime('/schedule/%Y/%m/%d/')}"

      if registered
        twitter.update "#{today.strftime('%Y/%m/%d')} の予定が公開されました。 #{uri}"

        characters = added_items.map {|item| normalizer.character item[:character] }.uniq.sort

        header = "#{today.strftime('%Y/%m/%d')} の登場キャラクター"
        self.update_characters twitter, characters, header
      else
        unless added_items.empty? && deleted_items.empty?
          twitter.update "#{today.strftime('%Y/%m/%d')} の予定が変更されました。 #{uri}"

          unless added_items.empty?
            characters = added_items.map {|item| normalizer.character item[:character] }.uniq.sort
            header = "#{today.strftime('%Y/%m/%d')} の追加対象キャラクター"
            self.update_characters twitter, characters, header
          end

          unless deleted_items.empty?
            characters = deleted_items.map {|item| normalizer.character item[:character] }.uniq.sort
            header = "#{today.strftime('%Y/%m/%d')} の中止対象キャラクター"
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
