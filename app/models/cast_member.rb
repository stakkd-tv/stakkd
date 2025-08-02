class CastMember < ApplicationRecord
  acts_as_list scope: :record

  # Associations
  belongs_to :record, polymorphic: true
  belongs_to :person

  # Validations
  validates_presence_of :character, :position
  validates_uniqueness_of :person_id, scope: [:record_type, :record_id]
end
