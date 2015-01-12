class PurolandGreeting::Costume < ActiveRecord::Base
  has_many :appearances, class_name: 'PurolandGreeting::Appearance', dependent: :delete_all
  has_many :greetings, class_name: 'PurolandGreeting::Greeting', through: :appearances
end
