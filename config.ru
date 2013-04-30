require 'bundler'
Bundler.require
require 'sprockets/sass/functions' # Avoid "tilt" lib warnings.

$:.push File.expand_path('lib', __dir__)

require 'purolandgreeting'

case ENV['RACK_ENV']
when 'production'
  require 'unicorn/oob_gc'
  use Unicorn::OobGC
end

map '/assets' do
  run PurolandGreeting::Application.sprockets
end

map '/' do
  run PurolandGreeting::Application
end
