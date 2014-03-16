class PurolandGreeting::Character < ActiveRecord::Base
  has_many :appearances, class_name: 'PurolandGreeting::Appearance'
  has_many :greetings, class_name: 'PurolandGreeting::Greeting', through: :appearances
  has_many :places, class_name: 'PurolandGreeting::Place', through: :greetings

  default_scope {
    order('name ASC')
  }

  def self.ranking
    PurolandGreeting::Appearance.joins(:character, :greeting).where('greetings.deleted = FALSE').order('score DESC').group(:character_name).select("characters.name AS character_name, COUNT(character_id) AS score").map {|item|
      Hashie::Mash.new(
        name: item.character_name,
        score: item.score.to_i
      )
    }
  end

  def place_ranking
    greetings.joins(:place).where('greetings.deleted = FALSE').group('place_name').order('score DESC').select("places.name AS place_name, COUNT(place_id) AS score").map {|item|
      Hashie::Mash.new(
        name: item.place_name,
        score: item.score.to_i
      )
    }
  end

end
