class Tagline < ApplicationRecord
  acts_as_list scope: :record

  # Associations
  belongs_to :record, polymorphic: true

  # Validations
  validates_presence_of :tagline, :position
end
