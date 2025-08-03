class CrewMember < ApplicationRecord
  # Associations
  belongs_to :record, polymorphic: true
  belongs_to :person
  belongs_to :job
end
