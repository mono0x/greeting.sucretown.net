require 'nkf'
require 'set'

module PurolandGreeting
  class Normalizer
    attr_reader :character_table, :ignore_costume_table, :place_table

    def initialize
      open('data/normalize.json', 'r:utf-8') do |f|
        json = JSON.parse(f.read)
        @character_table = json['character']
        @ignore_costume_table = json['ignore_costume'].to_set
        @place_table = json['place']
        @default_minutes_by_place_table = json['default_minutes_by_place']
        @ignore_old_site_table = json['ignore_character_in_old_site'].to_set
        @ignore_new_site_table = json['ignore_character_in_new_site'].to_set
      end
    end

    def items(items)
      items.map {|item|
        item.merge(
          character: character_full_name(item[:character]),
          place: place(item[:place]),
        )
      }
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

    def default_minutes_by_place(name)
      name = place(name)
      @default_minutes_by_place_table[name]
    end

    def ignored_in_old_site?(name)
      @ignore_old_site_table.include? name
    end

    def ignored_in_new_site?(name)
      @ignore_new_site_table.include? name
    end

    private

    def convert(s)
      NKF.nkf '-W1 -Ww -m0Z1', s
    end
  end
end
