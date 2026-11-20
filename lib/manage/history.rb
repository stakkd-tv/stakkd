module Manage
  class History
    attr_reader :user

    BATCH_SIZE = 1000

    def initialize(user)
      @user = user
    end

    def add!(item, consumed_at:)
      # TODO: Protect against nil user?
      # TODO: Protect against unreleased items?
      items = item.tracking_items
      items.each_slice(BATCH_SIZE) do |batch|
        insert_batch(batch, consumed_at)
      end
      remove_related_items_from_watchlist(item)
    end

    def remove_all(item)
      items = item.tracking_items
      HistoryItem.where(user:, item: items).delete_all
    end

    def status_for(item)
      statuses_for([item])[item]
    end

    def statuses_for(items)
      items = normalize_items(items)
      return default_statuses(items) unless user

      sub_items = tracking_items_by_record(items)
      history_items = history_items_for(sub_items)

      sub_items.transform_values { |items| Tracking::Completion.new(items, history_items).status }
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

    def normalize_items(items)
      Array(items).compact
    end

    def default_statuses(items)
      items.index_with { :none }
    end

    def tracking_items_by_record(items)
      items.index_with do |item|
        item.tracking_items.to_a
      end
    end

    def history_items_for(sub_items)
      sub_items
        .values
        .flatten
        .uniq
        .then { |items| find_history_items(items) }
    end

    def find_history_items(items)
      return Set.new if items.empty?

      HistoryItem
        .where(user:, item: items)
        .distinct
        .pluck(:item_type, :item_id)
        .to_set
    end

    def remove_related_items_from_watchlist(item)
      watchlist = user.watchlist!
      watchlist.stack_items.where(item: item.ordered_related_records).destroy_all
    end
  end
end
