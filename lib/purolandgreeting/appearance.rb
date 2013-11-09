class PurolandGreeting::Appearance < ActiveRecord::Base
  attr_accessible :greeting_id, :character_id, :costume_id

  scope :only_deleted, -> {
    joins(:greeting).where('greetings.deleted = TRUE')
  }
  scope :without_deleted, -> {
    joins(:greeting).where('greetings.deleted = FALSE')
  }

  belongs_to :greeting, class_name: 'PurolandGreeting::Greeting'
  belongs_to :character, class_name: 'PurolandGreeting::Character'
  belongs_to :costume, class_name: 'PurolandGreeting::Costume'

  def character_with_costume
    costume ? "#{character.name} (#{costume.name})" : character.name
  end
end
