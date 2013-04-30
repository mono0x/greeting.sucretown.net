class PurolandGreeting::Schedule < ActiveRecord::Base
  attr_accessible :date

  has_many :greetings, class_name: 'PurolandGreeting::Greeting'
end
