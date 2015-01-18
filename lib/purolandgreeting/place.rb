class PurolandGreeting::Place < ActiveRecord::Base
  has_many :greetings, class_name: 'PurolandGreeting::Greeting', dependent: :delete_all

  def name_without_floor
    name.match(/\A(.+)\((?:\dF|他)\)\z/).to_a[1] || name
  end

  def floor
    name.match(/\((\dF|他)\)/).to_a[1]
  end

end
