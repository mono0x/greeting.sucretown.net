module PurolandGreeting
  class TwitterUpdater
    def run(today, now, registered, diff)
      twitter = Twitter::REST::Client.new do |config|
        config.consumer_key = ENV['TWITTER_CONSUMER_KEY']
        config.consumer_secret = ENV['TWITTER_CONSUMER_SECRET']
        config.access_token = ENV['TWITTER_ACCESS_TOKEN']
        config.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
      end

      uri = "#{ENV['ROOT_URI']}#{today.strftime('/schedule/%Y/%m/%d/')}"

      if registered
        tweet = twitter.update("#{today.strftime('%Y/%m/%d')} の予定が公開されました。 #{uri} #ピューロランド")

        header = "#{today.strftime('%Y/%m/%d')} の登場キャラクター"
        self.update_items twitter, diff.characters.to_a, header, tweet
      else
        unless diff.empty?
          time = now.strftime('%H:%M')
          tweet = twitter.update("#{today.strftime('%Y/%m/%d')} の予定が変更されました。 (#{time}) #{uri} #ピューロランド")

          header = "#{today.strftime('%Y/%m/%d')} の変更対象キャラクター (#{time})"
          tweet = self.update_items(twitter, diff.characters.to_a, header, tweet)

          tables = [ '追加', '中止' ].zip([ diff.added_by_greeting, diff.deleted_by_greeting ])

          tables.each do |title, table|
            table.group_by {|greeting, characters|
              characters
            }.map {|characters, pairs|
              [ characters, pairs.map {|pair| pair[0] }.to_a ]
            }.sort_by {|characters, greetings|
              greetings.map {|g|
                g.values_at(:end_at, :start_at)
              }.flatten
            }.each do |characters, greetings|
              header = "#{characters.join('と')} の#{title}分 (#{time})"
              parts = greetings.sort_by {|greeting| greeting.values_at(:end_at, :start_at) }.map {|greeting|
                "#{greeting[:start_at].strftime('%H:%M')}-#{greeting[:end_at].strftime('%H:%M')} #{greeting[:place]}"
              }
              self.update_items twitter, parts, header, tweet
            end
          end
        end
      end
    end

    private

    def update_items(twitter, items, header, footer = nil, tweet)
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
        tweet = twitter.update([ "#{header}#{pager}:", group, footer ].flatten.compact.join(separator), in_reply_to_status: tweet)
      end

      tweet
    end
  end
end
