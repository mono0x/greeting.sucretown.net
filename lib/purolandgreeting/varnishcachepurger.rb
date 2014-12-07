require 'uri'

module PurolandGreeting
  class VarnishCachePurger
    def run(registered = nil, diff = nil)
      uri = URI.parse(ENV['VARNISH_URL'])      
      varnish = Varnish::Client.new(uri.host, uri.port, ENV['ROOT_URI'])
      varnish.purge '.*'
    rescue
      STDERR.puts $!
    end
  end
end
