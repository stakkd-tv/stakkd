class Job < ApplicationRecord
  include Typesense

  DIRECTOR = "Director"
  CREATOR = "Creator"
  WRITER = "Writer"

  typesense do
    attributes :department, :name

    predefined_fields [
      {"name" => "name", "type" => "string", "sort" => true},
      {"name" => "department", "type" => "string", "sort" => true}
    ]
  end

  # Validations
  validates :name, :department, presence: true
end
