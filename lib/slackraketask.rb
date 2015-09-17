require 'rake/tasklib'
require 'json'
require 'net/http'
require 'uri'

class SlackRakeTask < Rake::TaskLib
  attr_accessor :webhook_uri
  attr_accessor :username
  attr_accessor :channel
  attr_accessor :icon_uri
  attr_accessor :icon_emoji
  attr_accessor :send_name

  def initialize
    @webhook_uri = ENV['SLACK_WEBHOOK_URL']
    @username = ENV['SLACK_USERNAME']
    @channel = ENV['SLACK_CHANNEL'] || '#general'
    @icon_uri = ENV['SLACK_ICON_URL']
    @icon_emoji = ENV['SLACK_ICON_EMOJI']
    @send_name = :send
    yield self if block_given?
    define
  end

  def define
    task @send_name, [ :text ] do |t, args|
      payload = {
        'text' => args[:text],
      }
      payload['username']   = @username   if @username
      payload['channel']    = @channel    if @channel
      payload['icon_url']   = @icon_uri   if @icon_uri
      payload['icon_emoji'] = @icon_emoji if @icon_emoji

      uri = URI.parse(@webhook_uri)
      http = Net::HTTP.post_form(uri, { 'payload' => payload.to_json })
    end
  end
end
