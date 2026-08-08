module Manage
  class History
    attr_reader :user

    BATCH_SIZE = 1000

    def initialize(user)
      @user = user
    end

    def add!(items, consumed_at:)
      items.each_slice(BATCH_SIZE) do |batch|
        insert_batch(batch, consumed_at)
      end
    end

    private

    def insert_batch(batch, consumed_at)
      current_time = Time.current
      rows = batch.map do |item|
        history_item(item, consumed_at, current_time)
      end
      HistoryItem.insert_all!(rows)
    end

    def history_item(item, consumed_at, current_time)
      {
        user_id: user.id,
        item_type: item.class.polymorphic_name,
        item_id: item.id,
        consumed_at: resolve_consumed_at(item, consumed_at),
        created_at: current_time,
        updated_at: current_time
      }
    end

    def resolve_consumed_at(item, consumed_at)
      return item.history_release_date if consumed_at == :release_date
      consumed_at
    end
  end
end
