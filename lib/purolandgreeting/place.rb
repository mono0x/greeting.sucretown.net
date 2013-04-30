class PurolandGreeting::Place < ActiveRecord::Base
  attr_accessible :name

  has_many :greetings, class_name: 'PurolandGreeting::Greeting'
end
