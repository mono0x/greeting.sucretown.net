class PurolandGreeting::TemporarySchedule < ActiveRecord::Base
  has_many :appearances, class_name: 'PurolandGreeting::TemporaryAppearance'
  has_many :characters, class_name: 'PurolandGreeting::Character', through: :appearances
end
