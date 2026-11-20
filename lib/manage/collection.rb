module Manage
  class Collection
    attr_reader :user

    def initialize(user)
      @user = user
    end

    # Explicit all/owned scope keeps format edits from silently adding episodes.
    def add!(record, formats: [], scope: :all)
      raise ArgumentError, "Invalid scope" unless [:all, :owned].include?(scope)
      validate_record!(record)
      raise ArgumentError, "Cannot collect an unreleased title" unless record.released?

      mutate do
        items = record.tracking_items.to_a
        entries = user.collection_items.where(item: items).to_a
        if scope == :all
          owned = entries.map { |entry| [entry.item_type, entry.item_id] }.to_set
          items.each do |item|
            next if owned.include?([item.class.polymorphic_name, item.id])
            entries << CollectionItem.create!(user:, item:)
          end
        end
        next [] if entries.empty?

        resolved = formats.map { |format| resolve_format!(format) }.uniq(&:id)
        entries.each do |entry|
          resolved.each do |format|
            CollectionItemFormat.find_or_create_by!(collection_item: entry, collection_format: format)
          end
        end
        entries
      end
    end

    def remove_formats!(record, formats:)
      validate_record!(record)
      mutate do
        ids = formats.map { |format| existing_format!(format).id }
        CollectionItemFormat.where(collection_item: entries_for(record), collection_format_id: ids).delete_all
        CollectionFormat.prune_unused_for(user.id)
      end
    end

    def remove_all!(record)
      validate_record!(record)
      mutate do
        entries_for(record).delete_all
        CollectionFormat.prune_unused_for(user.id)
      end
    end

    def status_for(record) = statuses_for([record])[record]

    def statuses_for(records)
      records = Array(records).compact
      return records.index_with { :none } unless user

      items_by_record = records.index_with { |record| record.tracking_items.to_a }
      items = items_by_record.values.flatten.uniq
      identities = user.collection_items.where(item: items).pluck(:item_type, :item_id)
      items_by_record.transform_values { |selection| Tracking::Completion.new(selection, identities).status }
    end

    private

    def mutate(&block)
      raise ArgumentError, "A persisted user is required" unless user&.persisted?
      user.with_lock(&block)
    end

    def validate_record!(record)
      unless [Movie, Episode, Show, Season].any? { |type| record.is_a?(type) } && record.persisted?
        raise ArgumentError, "A persisted movie, episode, show or season is required"
      end
    end

    def entries_for(record)
      user.collection_items.where(item: record.tracking_items.to_a)
    end

    def resolve_format!(format)
      return existing_format!(format) if format.is_a?(CollectionFormat) || format.is_a?(Integer)
      raise ArgumentError, "Format must be a name, ID or CollectionFormat" unless format.is_a?(String)

      name = format.strip
      raise ArgumentError, "Format name cannot be blank" if name.empty?
      common = CollectionFormat.common.find_by(normalized_name: name.downcase)
      common || CollectionFormat.find_or_create_by!(user:, normalized_name: name.downcase) { |custom| custom.name = name }
    end

    def existing_format!(format)
      id = format.is_a?(CollectionFormat) ? format.id : format
      CollectionFormat.available_to(user).find(id)
    end
  end
end
