class PurolandGreeting::Appearance < ActiveRecord::Base
  attr_accessible :greeting_id, :character_id

  scope :only_deleted, -> {
    joins(:greeting).where('greetings.deleted = TRUE')
  }
  scope :without_deleted, -> {
    joins(:greeting).where('greetings.deleted = FALSE')
  }

  belongs_to :greeting, class_name: 'PurolandGreeting::Greeting'
  belongs_to :character, class_name: 'PurolandGreeting::Character'
end
