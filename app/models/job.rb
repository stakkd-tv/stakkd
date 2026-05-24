class Job < ApplicationRecord
  include Typesense

  DIRECTOR = "Director"
  CREATOR = "Creator"
  WRITER = "Writer"

  typesense enqueue: true do
    attributes :department, :name

    predefined_fields [
      {"name" => "name", "type" => "string"},
      {"name" => "department", "type" => "string", "facet" => true}
    ]

    default_sorting_field "department"
  end

  # Validations
  validates :name, :department, presence: true
end
