class PurolandGreeting::Character < ActiveRecord::Base
  has_many :appearances, class_name: 'PurolandGreeting::Appearance', dependent: :delete_all
  has_many :greetings, class_name: 'PurolandGreeting::Greeting', through: :appearances
  has_many :places, class_name: 'PurolandGreeting::Place', through: :greetings

  default_scope {
    order('name ASC')
  }

  def self.ranking
    PurolandGreeting::Appearance.joins(:character, :greeting).where('greetings.deleted = FALSE').order('score DESC').group(:character_name).select("characters.name AS character_name, COUNT(character_id) AS score").map {|item|
      Hashie::Mash.new(
        name: item.character_name,
        score: item.score.to_i
      )
    }
  end

  def place_ranking
    greetings.active.joins(:place).where('greetings.deleted = FALSE').group('place_name').order('score DESC').select("places.name AS place_name, COUNT(place_id) AS score").map {|item|
      Hashie::Mash.new(
        name: item.place_name,
        score: item.score.to_i
      )
    }
  end

  def self.count_appeparances(character_id, date_from)
    PurolandGreeting::Schedule.find_by_sql([
      %q{
        SELECT COUNT(schedules.id) AS count
        FROM schedules
        JOIN greetings ON greetings.schedule_id = schedules.id
        JOIN appearances ON appearances.greeting_id = greetings.id
        JOIN characters ON characters.id = appearances.character_id
        WHERE
          schedules.date > :date_from
          AND characters.id = :character_id
      },
      {
        date_from: date_from,
        character_id: character_id,
      }
    ])[0].count
  end

  def self.count_appeparance_dates(character_id, date_from)
    PurolandGreeting::Schedule.find_by_sql([
      %q{
        SELECT COUNT(DISTINCT schedules.id) AS count
        FROM schedules
        JOIN greetings ON greetings.schedule_id = schedules.id
        JOIN appearances ON appearances.greeting_id = greetings.id
        JOIN characters ON characters.id = appearances.character_id
        WHERE
          schedules.date > :date_from
          AND characters.id = :character_id
      },
      {
        date_from: date_from,
        character_id: character_id,
      }
    ])[0].count
  end

  def self.count_greetings_by_month(character_id, date_from)
    PurolandGreeting::Schedule.find_by_sql([
      %q{
        SELECT
          DATE_PART('year', date) AS year,
          DATE_PART('month', date) AS month,
          COUNT(schedules) AS count
        FROM schedules
        JOIN greetings ON greetings.schedule_id = schedules.id
        JOIN appearances ON appearances.greeting_id = greetings.id
        JOIN characters ON characters.id = appearances.character_id
        WHERE
          date > :date_from
          AND characters.id = :character_id
        GROUP BY year, month
        ORDER BY year, month
      },
      {
        date_from: date_from,
        character_id: character_id,
      }
    ])
  end

end
