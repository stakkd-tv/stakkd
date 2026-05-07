module HasBlob
  extend ActiveSupport::Concern

  included do
    delegate :dominant_colour, :filtered_colours, to: :blob
  end
end
