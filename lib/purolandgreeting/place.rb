class PurolandGreeting::Place < ActiveRecord::Base
  has_many :greetings, class_name: 'PurolandGreeting::Greeting', dependent: :delete_all
end
