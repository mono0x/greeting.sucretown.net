require 'logger'
require 'csv'

module PurolandGreeting
  class Database
    def self.connect
      ActiveRecord::Base.establish_connection ENV['DATABASE_URL']
      logger = Logger.new(STDERR)
      logger.level = Logger::WARN
      ActiveRecord::Base.logger = logger
      ActiveRecord::Base.default_timezone = :local
    end

    def self.register(items: [], nextday_items: [], new_items: [], new_nextday_items: [])
      normalizer = Normalizer.new

      keys = [ :character, :place, :start_at, :end_at, :deleted ].freeze
      nextday_keys = [ :character, :date, :deleted ].freeze

      deleted_items = nil
      added_items = nil

      items = [
        items.select {|item| !normalizer.ignored_in_old_site?(item[:character]) },
        new_items.select {|item| normalizer.include_in_new_site?(item[:character]) },
      ].flatten(1)

      items.each do |item|
        item[:end_at] ||= item[:start_at] + (normalizer.default_minutes_by_place(item[:place]) || 30) * 60
      end

      nextday_items = [
        nextday_items.select {|item| !normalizer.ignored_in_old_site?(item[:character]) },
        new_nextday_items.select {|item| normalizer.include_in_new_site?(item[:character]) },
      ].flatten(1)

      ActiveRecord::Base.transaction do
        dates = items.map {|item| item[:start_at].to_date }.uniq
        before = Appearance.joins(greeting: :schedule).where('schedules.date IN ( ? )', dates).map {|a|
            Hash[keys.zip([ a.raw_character_name, a.greeting.raw_place_name, a.greeting.start_at, a.greeting.end_at, a.greeting.deleted ])]
        }.to_set
        after = items.map {|item|
          { deleted: false }.merge item
        }.to_set

        deleted_items = (before - after).select {|item| !item[:deleted] }
        deleted_items.each do |item|
          character_name, costume_name = normalizer.character(item[:character])
          character = Character.where(name: character_name).first
          costume = Costume.where(name: costume_name).first if costume_name
          place = Place.where(name: normalizer.place(item[:place])).first
          schedule = Schedule.where(date: item[:start_at].to_date).first
          greeting = Greeting.where(
            start_at: item[:start_at],
            end_at: item[:end_at],
            place_id: place.id,
            schedule_id: schedule.id,
            deleted: false).first or next

          appearance = Appearance.where(
            character_id: character.id,
            costume_id: costume && costume.id,
            greeting_id: greeting.id).first or next

          deleted_greeting = Greeting.where(
            start_at: item[:start_at],
            end_at: item[:end_at],
            place_id: place.id,
            schedule_id: schedule.id,
            deleted: true).first_or_create(raw_place_name: item[:place])

          appearance.update_attribute :greeting_id, deleted_greeting.id
          greeting.destroy if greeting.characters.empty?
        end

        added_items = []
        (after - before).each do |item|
          character_name, costume_name = normalizer.character(item[:character])
          character = Character.where(name: character_name).first_or_create
          costume = Costume.where(name: costume_name).first_or_create if costume_name
          place = Place.where(name: normalizer.place(item[:place])).first_or_create
          schedule = Schedule.where(date: item[:start_at].to_date).first_or_create
          greeting = Greeting.where(
            start_at: item[:start_at],
            end_at: item[:end_at],
            place_id: place.id,
            schedule_id: schedule.id,
            deleted: item[:deleted]).first_or_create(raw_place_name: item[:place])
          Appearance.where(
            character_id: character.id,
            costume_id: costume && costume.id,
            greeting_id: greeting.id
          ).first_or_create(raw_character_name: item[:character]) {
            added_items << item
          }
        end

        unless nextday_items.empty?
          dates = nextday_items.map {|item| item[:date] }.uniq
          before_nextday = TemporaryAppearance.joins(:temporary_schedule).where('temporary_schedules.date IN ( ? )', dates).map {|a|
            Hash[nextday_keys.zip([ a.raw_character_name, a.temporary_schedule.date, a.deleted ])]
          }.to_set
          after_nextday = nextday_items.map {|item|
            { deleted: false }.merge item
          }.to_set

          (before_nextday - after_nextday).select {|item| !item[:deleted] }.each do |item|
            character_name, _ = normalizer.character(item[:character])
            character = Character.where(name: character_name).first_or_create
            schedule = TemporarySchedule.where(date: item[:date]).first_or_create
            TemporaryAppearance.where(character_id: character.id, temporary_schedule_id: schedule.id).update_all deleted: true
          end

          (after_nextday - before_nextday).each do |item|
            character_name, _ = normalizer.character(item[:character])
            character = Character.where(name: character_name).first_or_create
            schedule = TemporarySchedule.where(date: item[:date]).first_or_create
            TemporaryAppearance.where(character_id: character.id, temporary_schedule_id: schedule.id, deleted: item[:deleted]).first_or_create(raw_character_name: item[:character])
          end

          nextday_items.map {|item| item[:date] }.uniq.each do |date|
            TemporarySchedule.where(date: date).first_or_create
          end
        end

      end

      [ added_items, deleted_items, ]
    end

    def self.import(src)
      register(items: LTSV.load(src).map {|item|
        {
          character: item[:character],
          place: item[:place],
          start_at: Time.parse(item[:start_at]),
          end_at: Time.parse(item[:end_at]),
          deleted: (item[:deleted] == 'true') || false,
        }
      })
    end

    def self.import_ohtake_csv(src)
      src = src.each_line.to_a[1..-1].join
      csv = CSV.new(src, headers: true, header_converters: :symbol)
      register(items: csv.map {|item|
        {
          character: item[:name],
          place: item[:location],
          start_at: Time.parse(item[:start]),
          end_at: Time.parse(item[:end]),
          deleted: false,
        }
      })
    end

    def self.dump
      Appearance.includes(:character, greeting: :place).order('greeting_id ASC, character_id ASC').map {|a|
        {
          character: a.raw_character_name,
          place: a.greeting.raw_place_name,
          start_at: a.greeting.start_at,
          end_at: a.greeting.end_at,
          deleted: a.greeting.deleted,
          normalized_character: a.character.name,
          normalized_place: a.greeting.place.name,
        }
      }
    end

    def self.export
      dump.map {|item| LTSV.dump(item) }.join("\n")
    end

    def self.dump_by_date(date)
      Appearance.find_by_sql([
        %{
          SELECT
            appearances.raw_character_name AS raw_character_name,
            greetings.raw_place_name AS raw_place_name,
            greetings.start_at AS start_at,
            greetings.end_at AS end_at
          FROM appearances
          JOIN greetings ON greetings.id = appearances.greeting_id
          JOIN schedules ON schedules.id = greetings.schedule_id
          WHERE
            schedules.date = :date
            AND greetings.deleted = FALSE
          ORDER BY end_at, start_at, raw_place_name, raw_character_name
        },
        {
          date: date,
        }
      ]).map {|a|
        {
          character: a.raw_character_name,
          place: a.raw_place_name,
          start_at: a.start_at,
          end_at: a.end_at,
        }
      }
    end

    def self.export_by_date(date)
      dump_by_date(date).map {|item| LTSV.dump(item) }.join("\n")
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
          Greeting.where('place_id = ?', before_place.id).update_all place_id: after_place.id
          before_place.destroy
        end
      end
    end
  end
end
