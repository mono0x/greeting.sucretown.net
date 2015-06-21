require 'rake/tasklib'

class DropboxRakeTask < Rake::TaskLib
  attr_accessor :consumer_key, :consumer_secret
  attr_accessor :authorize_name

  def initialize
    @consumer_key = ENV['DROPBOX_CONSUMER_KEY']
    @consumer_secret = ENV['DROPBOX_CONSUMER_SECRET']
    @authorize_name = :authorize
    yield self if block_given?
    define
  end

  def define
    task @authorize_name do
      flow = DropboxOAuth2FlowNoRedirect.new(@consumer_key, @consumer_secret)
      authorize_url = flow.start()

      # Have the user sign in and authorize this app
      STDERR.puts '1. Go to: ' + authorize_url
      STDERR.puts '2. Click "Allow" (you might have to log in first)'
      STDERR.puts '3. Copy the authorization code'
      STDERR.print 'Enter the authorization code here: '
      code = STDIN.gets.strip

      # This will fail if the user gave us an invalid authorization code
      access_token, user_id = flow.finish(code)
      puts access_token
    end
  end
end
