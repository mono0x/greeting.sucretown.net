require 'uri'

module PurolandGreeting
  class VarnishCachePurger
    def run(today = nil, now = nil, registered = nil, diff = nil)
      uri = URI.parse(ENV['VARNISH_URL'])      
      varnish = Varnish::Client.new(uri.host, uri.port, ENV['ROOT_URI'])
      if !diff || !diff.empty?
        varnish.purge '.*'
      end
    rescue
      STDERR.puts $!
    end
  end
end
