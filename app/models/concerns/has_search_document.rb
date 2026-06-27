module HasSearchDocument
  extend ActiveSupport::Concern

  included do
    has_one :search_document, as: :searchable

    after_save :create_or_update_search_document
    after_destroy :destroy_search_document
  end

  private

  def create_or_update_search_document
    aliases = AlternativeName.where(record: self).pluck(:name).join(", ")
    SearchDocument.find_or_initialize_by(searchable: self).update(
      translated_title:,
      original_title:,
      aliases:
    )
  end

  def destroy_search_document
    search_document&.destroy
  end
end
