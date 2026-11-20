class CollectionItemFormat < ApplicationRecord
  belongs_to :collection_item, inverse_of: :collection_item_formats
  belongs_to :collection_format

  validates :collection_format_id, uniqueness: {scope: :collection_item_id}
  validate :format_available_to_owner
  after_destroy :prune_unused_formats

  private

  def format_available_to_owner
    return unless collection_item && collection_format
    return if collection_format.user_id.nil? || collection_format.user_id == collection_item.user_id

    errors.add(:collection_format, "must be common or belong to the collection owner")
  end

  def prune_unused_formats
    # An independently loaded assignment may not have its parent loaded. Query the
    # owner ID directly to avoid lazy-loading the association under strict loading.
    CollectionFormat.prune_unused_for(CollectionItem.where(id: collection_item_id).pick(:user_id))
  end
end
