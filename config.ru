require 'bundler'
Bundler.require

$:.push File.expand_path('lib', __dir__)

require 'purolandgreeting'

case ENV['RACK_ENV']
when 'production'
  require 'unicorn/worker_killer'
  use Unicorn::WorkerKiller::MaxRequests
  use Unicorn::WorkerKiller::Oom, 128 * (1024 ** 2), 256 * (1024 ** 2)
end

use Rack::Timeout
Rack::Timeout.timeout = 20

map '/' do
  run PurolandGreeting::Application
end
