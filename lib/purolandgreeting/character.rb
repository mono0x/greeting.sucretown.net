class PurolandGreeting::Character < ActiveRecord::Base
  attr_accessible :name

  has_many :appearances, class_name: 'PurolandGreeting::Appearance'
  has_many :greetings, class_name: 'PurolandGreeting::Greeting', through: :appearances
end
