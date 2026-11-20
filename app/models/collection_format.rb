class CollectionFormat < ApplicationRecord
  COMMON_NAMES = ["DVD", "Blu-ray", "4K Ultra HD Blu-ray", "Digital"].freeze

  belongs_to :user, optional: true
  has_many :collection_item_formats, dependent: :restrict_with_exception

  before_validation :normalize_name
  validates :name, presence: true
  validates :normalized_name, presence: true, uniqueness: {scope: :user_id}

  scope :common, -> { where(user_id: nil) }
  scope :available_to, ->(user) { where(user_id: [nil, user.id]) }

  def self.prune_unused_for(user_id)
    return unless user_id

    where(user_id:).where.not(id: CollectionItemFormat.select(:collection_format_id)).delete_all
  end

  private

  def normalize_name
    self.name = name.to_s.strip
    self.normalized_name = name.downcase
  end
end
