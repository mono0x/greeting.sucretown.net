# -*- coding: utf-8 -*-

module PurolandGreeting
  class CrawlerTask
    def self.register
      self.update true
    end

    def self.update(register = false)
      added_items, deleted_items, registered = p(Crawler.update(register))

      twitter = Twitter::REST::Client.new do |config|
        config.consumer_key = ENV['TWITTER_CONSUMER_KEY']
        config.consumer_secret = ENV['TWITTER_CONSUMER_SECRET']
        config.access_token = ENV['TWITTER_ACCESS_TOKEN']
        config.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
      end

      normalizer = Normalizer.new

      if registered
        today = Date.today
        characters = added_items.map {|item| normalizer.character item[:character] }.uniq.sort

        header = "#{today.strftime('%Y/%m/%d')} の登場キャラクター #{ENV['ROOT_URI']}#{today.strftime('/schedule/%Y/%m/%d/')}"
        separator = ' '

        header_size = header.size + 8 # ' (n/m): '
        separator_size = separator.size

        groups = []
        group = []
        characters.each do |character|
          if header_size + group.map(&:size).inject(0, &:+) + group.size * separator_size + character.size > 140
            groups << group
            group = []
          else
            group << character
          end
        end
        groups << group unless group.empty?

        groups.each_with_index do |group, i|
          twitter.update "#{header} (#{i + 1}/#{groups.size}): #{group.join(separator)}"
        end

      end

    end


  end
end
