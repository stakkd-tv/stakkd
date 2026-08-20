class Franchise < ApplicationRecord
  include Searchable
  include Slugify
  include HasGalleries
  include Routable

  searchable do
    attributes :original_title, :translated_title, :slug

    set_schema [
      {"name" => "original_title", "type" => "string"},
      {"name" => "translated_title", "type" => "string", "sort" => true},
      {"name" => "slug", "type" => "string"}
    ]
  end

  # Associations
  has_many :franchise_items, dependent: :destroy
  has_many :ordered_franchise_items, -> { ordered }, class_name: "FranchiseItem"
  has_galleries :posters, :backgrounds, :logos

  # Validations
  validates_presence_of :translated_title, :original_title

  def slug=(value)
    self.title_kebab = value
  end

  def to_s = translated_title

  private

  def slug_source = translated_title

  def _slug = title_kebab
end
