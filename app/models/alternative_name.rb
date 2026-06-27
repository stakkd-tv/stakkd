class AlternativeName < ApplicationRecord
  # Associations
  belongs_to :country
  belongs_to :record, polymorphic: true

  # Validations
  validates_presence_of :name

  # Callbacks
  after_save :index_record
  after_destroy :index_record, prepend: true

  def self.inheritance_column = nil

  private

  def index_record
    record.try(:index!)
  end
end
