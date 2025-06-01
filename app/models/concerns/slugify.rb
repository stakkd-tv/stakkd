module Slugify
  extend ActiveSupport::Concern

  included do
    before_validation :slugify
  end

  class_methods do
    def from_slug(slug)
      id = slug.split("-").last.to_i
      find(id)
    end
  end

  def slug=(value)
    raise "Implement in model"
  end

  def slug = "#{_slug}-#{id}"

  def to_param = slug

  private

  def slugify
    return if _slug.present?
    self.slug = slug_source # e.g. " Cote  d'Ivoire "
      &.downcase # Downcase the string e.g. " cote  d'ivoire "
      &.gsub(/[\p{^Alnum}]/, " ") # Replace all alphanumeric characters e.g. " cote  d ivoire "
      &.strip # Strip any leading or trailing spaces e.g. "cote  d ivoire"
      &.gsub(/\s+/, " ") # Replace multiple spaces with one space e.g. "cote d ivoire"
      &.tr(" ", "-") # Replace all spaces with a hyphen e.g. "cote-d-ivoire"
  end

  def slug_source = raise "Implement in model"

  def _slug = raise "Implement in model"
end
