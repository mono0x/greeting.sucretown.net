require 'logger'

module PurolandGreeting
  class Database
    def self.connect
      ActiveRecord::Base.establish_connection ENV['DATABASE_URL']
      ActiveRecord::Base.logger = Logger.new(STDERR)
    end

    def self.register(items)
      ActiveRecord::Base.transaction do
        normalizer = Normalizer.new
        items.each do |item|
          character = Character.where(name: normalizer.character(item[:character])).first_or_create
          place = Place.where(name: normalizer.place(item[:place])).first_or_create
          schedule = Schedule.where(date: item[:start_at].to_date).first_or_create
          greeting = Greeting.where(
            start_at: item[:start_at],
            end_at: item[:end_at],
            place_id: place.id,
            schedule_id: schedule.id,
            raw_place_name: item[:place]).first_or_create
          appearance = Appearance.where(
            character_id: character.id,
            greeting_id: greeting.id,
            raw_character_name: item[:character]).first_or_create
        end
      end
    end

    def self.import(src)
      register LTSV.load(src)
    end

    def self.export
      Appearance.order('greeting_id ASC, character_id ASC').map {|a|
        LTSV.dump({
          character: a.raw_character_name,
          place: a.greeting.raw_place_name,
          start_at: a.greeting.start_at,
          end_at: a.greeting.end_at,
          normalized_character: a.character.name,
          normalized_place: a.greeting.place.name,
        })
      }.join("\n")
    end

    def self.normalize
      ActiveRecord::Base.transaction do
        normalizer = Normalizer.new
        normalizer.character_table.each do |before, after|
          before_character = Character.find_by_name(before) or next
          after_character = Character.where(name: after).first_or_create
          Appearance.where('character_id = ?', before_character.id).update_all character_id: after_character.id
          before_character.destroy
        end
        normalizer.place_table.each do |before, after|
          before_place = Place.find_by_name(before) or next
          after_place = Place.where(name: after).first_or_create
          Greeting.where('place_id = ?', before_place.id).update_all character_id: after_place.id
          before_place.destroy
        end
      end
    end
  end
end
