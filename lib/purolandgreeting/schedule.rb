class PurolandGreeting::Schedule < ActiveRecord::Base
  attr_accessible :date

  has_many :greetings, class_name: 'PurolandGreeting::Greeting'

  def self.months
    select("DATE_TRUNC('month', date) AS month").group("DATE_TRUNC('month', date)").order('month DESC').map { |c| Date.parse(c.month) }
  end

  def self.by_month(month)
    where('date >= ? AND date < ?', month, month >> 1)
  end
end
