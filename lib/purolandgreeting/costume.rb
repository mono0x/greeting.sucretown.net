class PurolandGreeting::Costume < ActiveRecord::Base
  has_many :appearances, class_name: 'PurolandGreeting::Appearance'
  has_many :greetings, class_name: 'PurolandGreeting::Greeting', through: :appearances
end
