FactoryGirl.define do
  factory :schedule, class: PurolandGreeting::Schedule do
    date Date.new(2015, 3, 6)
  end

  factory :schedule_nextday, class: PurolandGreeting::Schedule do
    date Date.new(2015, 3, 7)
  end

  factory :schedule_may, class: PurolandGreeting::Schedule do
    date Date.new(2015, 5, 5)
  end



end
