module PurolandGreeting
  class Difference
    def initialize(added, deleted)
      @added = added
      @deleted = deleted
    end

    def empty?
      @added.empty? && @deleted.empty?
    end

    def added_by_greeting
      by_greeting @added
    end

    def deleted_by_greeting
      by_greeting @deleted
    end

    def characters
      [ @added, @deleted ].map {|items|
        items.map {|item| item[:character] }
      }.inject(&:|).sort
    end

    private

    def by_greeting(items)
      Hash[items.group_by {|item| item.reject {|k, v| k == :character } }.map {|greeting, grouped_items|
        [ greeting, grouped_items.map {|item| item[:character] } ]
      }]
    end
  end
end
