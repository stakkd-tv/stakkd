module AttachmentExtension
  extend ActiveSupport::Concern

  included do
    after_create :extract_colour
  end

  def dominant_colour = colours.last

  private

  def extract_colour = ExtractColourJob.perform_later(id)
end
