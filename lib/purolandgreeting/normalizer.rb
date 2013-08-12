require 'nkf'

module PurolandGreeting
  class Normalizer
    attr_reader :character_table, :place_table

    def initialize
      open('data/normalize.json') do |f|
        json = JSON.parse(f.read)
        @character_table = json['character']
        @place_table = json['place']
      end
    end

    def character(name)
      name = convert(name)
      @character_table[name] || name
    end

    def place(name)
      name = convert(name)
      @place_table[name] || name
    end

    private

    def convert(s)
      NKF.nkf '-W1 -Ww -m0Z1', s
    end
  end
end
