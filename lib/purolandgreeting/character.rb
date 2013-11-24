class PurolandGreeting::Character < ActiveRecord::Base
  attr_accessible :name

  has_many :appearances, class_name: 'PurolandGreeting::Appearance'
  has_many :greetings, class_name: 'PurolandGreeting::Greeting', through: :appearances

  def self.ranking
    PurolandGreeting::Appearance.joins(:character, :greeting).where('greetings.deleted = FALSE').order('score DESC').group(:character_name).select("characters.name AS character_name, COUNT(character_id) AS score").map {|item|
      Hashie::Mash.new(
        name: item.character_name,
        score: item.score.to_i
      )
    }
  end

end
