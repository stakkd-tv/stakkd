module Tracking
  class Completion
    def initialize(items, recorded_identities)
      @identities = items.map { |item| [item.class.polymorphic_name, item.id] }.uniq
      @recorded_identities = recorded_identities.to_set
    end

    def status
      return :none if @identities.empty?

      count = @identities.count { |identity| @recorded_identities.include?(identity) }
      return :none if count.zero?

      (count == @identities.size) ? :completed : :partial
    end
  end
end
