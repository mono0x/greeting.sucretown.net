class PurolandGreeting::Appearance < ActiveRecord::Base
  attr_accessible :greeting_id, :character_id

  belongs_to :greeting, class_name: 'PurolandGreeting::Greeting'
  belongs_to :character, class_name: 'PurolandGreeting::Character'
end
