class PurolandGreeting::Schedule < ActiveRecord::Base
  has_many :greetings, class_name: 'PurolandGreeting::Greeting', dependent: :delete_all
  has_many :appearances, class_name: 'PurolandGreeting::Appearance', through: :greetings
  has_many :characters, class_name: 'PurolandGreeting::Character', through: :appearances

  scope :by_month, lambda {|month|
    where('date >= ? AND date < ?', month, month >> 1)
  }

  def self.months
    #select("DATE_TRUNC('month', date) AS month").group("DATE_TRUNC('month', date)").order('month DESC').map { |c| Date.parse(c.month) }
    select("DATE_TRUNC('month', date) AS month").group("DATE_TRUNC('month', date)").order('month DESC').map { |c| c.month.to_date }
  end

  def self.count_dates(date_from)
    find_by_sql([
      %q{
        SELECT COUNT(schedules.id) AS count
        FROM schedules
        WHERE
          schedules.date > :date_from
      },
      {
        date_from: date_from,
      }
    ])[0].count
  end

  def next_schedule
    self.class.where('date > ?', date).order('date ASC').first
  end

  def prev_schedule
    self.class.where('date < ?', date).order('date DESC').first
  end
end
