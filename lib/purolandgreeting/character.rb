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

  def self.count_appeparances_by_place(character_id)
    PurolandGreeting::Greeting.find_by_sql([
      %q{
        SELECT
          places.name,
          x.count
        FROM (
          SELECT
            places.id AS place_id,
            COUNT(places.id) AS count
          FROM greetings
          JOIN places ON places.id = greetings.place_id
          JOIN appearances ON appearances.greeting_id = greetings.id
          JOIN characters ON characters.id = appearances.character_id
          WHERE
            characters.id = :character_id
            AND NOT greetings.deleted
          GROUP BY places.id
        ) x
        JOIN places ON places.id = x.place_id
        ORDER BY x.count DESC
      },
      {
        character_id: character_id,
      }
    ])
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
          AND NOT greetings.deleted
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
          AND NOT greetings.deleted
      },
      {
        date_from: date_from,
        character_id: character_id,
      }
    ])[0].count
  end

  def self.count_greetings_by_month(character_id)
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
          characters.id = :character_id
          AND NOT greetings.deleted
        GROUP BY year, month
        ORDER BY year, month
      },
      {
        character_id: character_id,
      }
    ])
  end

end
