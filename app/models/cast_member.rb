class CastMember < ApplicationRecord
  acts_as_list scope: :record

  # Associations
  belongs_to :record, polymorphic: true
  belongs_to :person

  # Validations
  validates_presence_of :character, :position
end
