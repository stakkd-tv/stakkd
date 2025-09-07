module AttachmentExtension
  extend ActiveSupport::Concern

  included do
    after_create :extract_colour
  end

  def dominant_colour
    return "#f7567c" unless filtered_colours.any?

    filtered_colours.max_by do |hex|
      r, g, b = hex_to_rgb(hex)
      # Find the most saturated colour
      ([r, g, b].max - [r, g, b].min)
    end
  end

  def filtered_colours
    colours.reject do |hex|
      r, g, b = hex_to_rgb(hex)
      br = brightness(r, g, b)

      is_dull_or_gray?(r, g, b, threshold: 5) || br < 80 || br > 210
    end
  end

  private

  def extract_colour = ExtractColourJob.perform_later(id)

  # TODO: Extract to class
  def hex_to_rgb(hex)
    hex = hex.delete("#")
    r = hex[0..1].to_i(16)
    g = hex[2..3].to_i(16)
    b = hex[4..5].to_i(16)
    [r, g, b]
  end

  def brightness(r, g, b)
    0.2126 * r + 0.7152 * g + 0.0722 * b
  end

  def is_dull_or_gray?(r, g, b, threshold: 15)
    rg = (r - g).abs
    rb = (r - b).abs
    gb = (g - b).abs

    rg < threshold && rb < threshold && gb < threshold
  end
end
