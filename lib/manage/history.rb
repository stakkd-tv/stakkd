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
      items = item.items_for_history
      items.each_slice(BATCH_SIZE) do |batch|
        insert_batch(batch, consumed_at)
      end
    end

    def remove_all(item)
      items = item.items_for_history
      HistoryItem.where(user:, item: items).delete_all
    end

    def status_for(item)
      statuses_for([item])[item]
    end

    def statuses_for(items)
      items = normalize_items(items)
      return default_statuses(items) unless user

      sub_items = items_for_history(items)
      history_items = history_items_for(sub_items)

      statuses_for_items(sub_items, history_items)
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
      items.index_with { :not_consumed }
    end

    def items_for_history(items)
      items.index_with do |item|
        item.items_for_history.to_a
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

    def statuses_for_items(sub_items, history_items)
      sub_items.transform_values do |items|
        status_for_items(items, history_items)
      end
    end

    def status_for_items(items, history_items)
      total = items.size
      return :not_consumed if total.zero?

      history_count = items.count do |sub_item|
        history_items.include?([sub_item.class.polymorphic_name, sub_item.id])
      end

      case history_count
      when 0 then :not_consumed
      when total then :consumed
      else :partially_consumed
      end
    end
  end
end
