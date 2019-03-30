module PurolandGreeting
  def self.root
    File.expand_path '..', __dir__
  end
end

require 'purolandgreeting/database'
require 'purolandgreeting/schedule'
require 'purolandgreeting/character'
require 'purolandgreeting/costume'
require 'purolandgreeting/greeting'
require 'purolandgreeting/place'
require 'purolandgreeting/appearance'
require 'purolandgreeting/temporary_schedule'
require 'purolandgreeting/temporary_appearance'
require 'purolandgreeting/fetcher'
require 'purolandgreeting/crawler'
require 'purolandgreeting/normalizer'
require 'purolandgreeting/difference'
require 'purolandgreeting/crawlertask'
require 'purolandgreeting/twitterupdater'
require 'purolandgreeting/gitbackuper'
require 'purolandgreeting/application'
