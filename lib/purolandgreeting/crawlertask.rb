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

      normalizer = Normalizer.new
      diff = Difference.new(normalizer.items(added_items), normalizer.items(deleted_items))

      sub_tasks = []
      sub_tasks << TwitterUpdater.new if ENV['TWITTER_CONSUMER_KEY']
      sub_tasks << VarnishCachePurger.new if ENV['VARNISH_URL']
      sub_tasks << GitBackuper.new

      sub_tasks.each do |task|
        task.run today, now, registered, diff
      end
    end
  end
end
