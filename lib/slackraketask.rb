require 'rake/tasklib'

require_relative 'slackclient'

class SlackRakeTask < Rake::TaskLib
  attr_accessor :client
  attr_accessor :send_name

  def initialize
    @client = SlackClient.new
    @send_name = :send
    yield self if block_given?
    define
  end

  def define
    task @send_name, [ :text ] do |t, args|
      @client.send args[:text]
    end
  end
end
