class PurolandGreeting::Schedule < ActiveRecord::Base
  has_many :greetings, class_name: 'PurolandGreeting::Greeting'
  has_many :appearances, class_name: 'PurolandGreeting::Appearance', through: :greetings
  has_many :characters, class_name: 'PurolandGreeting::Character', through: :appearances

  scope :by_month, lambda {|month|
    where('date >= ? AND date < ?', month, month >> 1)
  }

  def self.months
    #select("DATE_TRUNC('month', date) AS month").group("DATE_TRUNC('month', date)").order('month DESC').map { |c| Date.parse(c.month) }
    select("DATE_TRUNC('month', date) AS month").group("DATE_TRUNC('month', date)").order('month DESC').map { |c| c.month.to_date }
  end
end
