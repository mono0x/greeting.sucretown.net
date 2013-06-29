class PurolandGreeting::Greeting < ActiveRecord::Base
  attr_accessible :start_at, :end_at, :place_id, :schedule_id

  has_many :appearances, class_name: 'PurolandGreeting::Appearance'
  has_many :characters, class_name: 'PurolandGreeting::Character', through: :appearances
  belongs_to :place, class_name: 'PurolandGreeting::Place'
  belongs_to :schedule, class_name: 'PurolandGreeting::Schedule'

  def self.before_the_start(time = Time.now)
    where 'start_at > ?', time
  end

  def self.in_session(time = Time.now)
    where 'start_at <= ? AND end_at >= ?', time, time
  end

  def self.after_the_end(time = Time.now)
    where 'end_at < ?', time
  end

end
