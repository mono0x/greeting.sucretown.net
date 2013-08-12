require 'logger'

module PurolandGreeting
  class Database
    def self.connect
      ActiveRecord::Base.establish_connection ENV['DATABASE_URL']
      ActiveRecord::Base.logger = Logger.new(STDERR)
    end

    def self.register(items)
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
        })
      }.join("\n")
    end
  end
end
