require 'nkf'

module PurolandGreeting
  class Normalizer
    def initialize
      open('data/normalize.json') do |f|
        json = JSON.parse(f.read)
        @character = json['character']
        @place = json['place']
      end
    end

    def character(name)
      name = NKF.nkf('-W1 -Ww', name)
      @character[name] || name
    end

    def place(name)
      name = NKF.nkf('-W1 -Ww', name)
      @place[name] || name
    end
  end
end
