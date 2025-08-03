class CrewMember < ApplicationRecord
  # Associations
  belongs_to :record, polymorphic: true
  belongs_to :person
  belongs_to :job

  # Validations
  validates_uniqueness_of :person_id, scope: [:record_type, :record_id]
end
