require 'date'

module PurolandGreeting
  class Crawler
    def update
      Fetcher.fetch.each do |item|
        character = Character.where(name: item[:character]).first_or_create
        place = Place.where(name: item[:place]).first_or_create
        schedule = Schedule.where(date: item[:start_at].to_date).first_or_create
        greeting = Greeting.where(
          start_at: item[:start_at],
          end_at: item[:end_at],
          place_id: place.id,
          schedule_id: schedule.id).first_or_create
        appearance = Appearance.where(
          character_id: character.id,
          greeting_id: greeting.id).first_or_create
      end
    end
  end
end
