class PurolandGreeting::Appearance < ActiveRecord::Base
  belongs_to :greeting, class_name: 'PurolandGreeting::Greeting'
  belongs_to :character, class_name: 'PurolandGreeting::Character'
  belongs_to :costume, class_name: 'PurolandGreeting::Costume'

  delegate :schedule, to: :greeting

  def greeting
    PurolandGreeting::Greeting.unscoped { super }
  end

  def character_with_costume
    costume ? "#{character.name} (#{costume.name})" : character.name
  end

  def self.count_by_month
    joins(greeting: :schedule).group("year, month").select("COUNT(appearances.id) AS appearance_count, DATE_PART('year', date) AS year, DATE_PART('month', date) AS month, COUNT(DISTINCT schedules.id) AS days").map {|item|
      Hashie::Mash.new({
        appearances: item.appearance_count.to_i,
        days: item.days.to_i,
        year: item.year.to_i,
        month: item.month.to_i,
      })
    }
  end
end
