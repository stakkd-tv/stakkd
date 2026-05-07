class ExtractColourJob < ApplicationJob
  queue_as :default

  def perform(*args)
    blob = ActiveStorage::Blob.find_by(id: args.first)
    return unless blob.present?

    colours = Uploads::ColourExtractor.new(blob:).extract
    blob.update(colours:) if colours.any?
  end
end
