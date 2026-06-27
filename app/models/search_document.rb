class SearchDocument < ApplicationRecord
  delegated_type :searchable, types: ["Movie", "Show"]

  validates :searchable_type, uniqueness: {scope: :searchable_id}
end
