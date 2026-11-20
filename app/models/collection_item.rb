class CollectionItem < ApplicationRecord
  belongs_to :user
  belongs_to :item, polymorphic: true
  has_many :collection_item_formats, dependent: :destroy, inverse_of: :collection_item
  has_many :formats, through: :collection_item_formats, source: :collection_format

  before_destroy :preload_format_assignments, prepend: true

  validates :item_type, inclusion: {in: %w[Movie Episode]}
  validates :item_id, uniqueness: {scope: [:user_id, :item_type]}

  private

  def preload_format_assignments
    ActiveRecord::Associations::Preloader.new(records: [self], associations: :collection_item_formats).call
  end
end
