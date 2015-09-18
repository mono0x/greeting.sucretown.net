require 'json'
require 'net/http'
require 'uri'

class SlackClient
  attr_accessor :webhook_uri
  attr_accessor :username
  attr_accessor :channel
  attr_accessor :icon_uri
  attr_accessor :icon_emoji

  def initialize
    @webhook_uri = ENV['SLACK_WEBHOOK_URL']
    @username = ENV['SLACK_USERNAME']
    @channel = ENV['SLACK_CHANNEL'] || '#general'
    @icon_uri = ENV['SLACK_ICON_URL']
    @icon_emoji = ENV['SLACK_ICON_EMOJI']
    yield self if block_given?
  end

  def send(text, options = {})
    payload = {}
    payload[:username]   = @username   if @username
    payload[:channel]    = @channel    if @channel
    payload[:icon_url]   = @icon_uri   if @icon_uri
    payload[:icon_emoji] = @icon_emoji if @icon_emoji

    payload = payload.merge(options)

    payload['text'] = text

    uri = URI.parse(@webhook_uri)
    http = Net::HTTP.post_form(uri, { 'payload' => payload.to_json })
  end
end
