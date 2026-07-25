class Job < ApplicationRecord
  include Searchable

  DIRECTOR = "Director"
  CREATOR = "Creator"
  WRITER = "Writer"

  searchable do
    attributes :department, :name

    set_schema [
      {"name" => "name", "type" => "string", "sort" => true},
      {"name" => "department", "type" => "string", "sort" => true}
    ]
  end

  # Validations
  validates :name, :department, presence: true
end
