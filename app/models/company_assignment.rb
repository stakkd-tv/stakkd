class CompanyAssignment < ApplicationRecord
  self.strict_loading_by_default = true

  # Associations
  belongs_to :company
  belongs_to :record, polymorphic: true

  # Validations
  validates :company_id, uniqueness: {scope: [:record_type, :record_id]}
end
