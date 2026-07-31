class Franchise < ApplicationRecord
  include Slugify
  include HasGalleries

  # Associations
  has_galleries :posters, :backgrounds, :logos

  # Validations
  validates_presence_of :translated_title, :original_title

  def slug=(value)
    self.title_kebab = value
  end

  private

  def slug_source = translated_title

  def _slug = title_kebab
end
