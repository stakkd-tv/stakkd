class ExtractColourJob < ApplicationJob
  queue_as :default

  def perform(*args)
    attachment = ActiveStorage::Attachment.find_by(id: args.first)
    return unless attachment.present?

    colours = Uploads::ColourExtractor.new(attachment:).extract
    attachment.update(colours:) if colours.any?
  end
end
