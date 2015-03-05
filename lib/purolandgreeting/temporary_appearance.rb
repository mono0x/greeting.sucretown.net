class PurolandGreeting::TemporaryAppearance < ActiveRecord::Base
  belongs_to :temporary_schedule, class_name: 'PurolandGreeting::TemporarySchedule'
  belongs_to :character, class_name: 'PurolandGreeting::Character'
end
