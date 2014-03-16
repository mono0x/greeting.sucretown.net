require 'nkf'
require 'set'

module PurolandGreeting
  class Normalizer
    attr_reader :character_table, :ignore_costume_table, :place_table

    def initialize
      open('data/normalize.json') do |f|
        json = JSON.parse(f.read)
        @character_table = json['character']
        @ignore_costume_table = json['ignore_costume'].to_set
        @place_table = json['place']
      end
    end

    def character(name)
      name = convert(name)
      character, costume = name.match(/\A(.+?)(?:\((.+)\))?\z/).to_a.values_at(1, 2)
      [ @character_table[character] || character, @ignore_costume_table.include?(costume) ? nil : costume ]
    end

    def character_full_name(name)
      normalized = character(name)
      %{#{normalized[0]}#{" (#{normalized[1]})" if normalized[1]}}
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
