module HasGalleries
  extend ActiveSupport::Concern

  GALLERY_FALLBACKS = {
    posters: "2:3.png",
    backgrounds: "16:9.png",
    logos: "1:1.png",
    videos: "16:9.png",
    images: "2:3.png"
  }

  VARIANTS = {
    medium: [250, nil],
    small: [160, nil],
    thumb: [50, nil]
  }

  included do
    class_attribute :available_galleries, default: []
  end

  class_methods do
    def has_galleries(*galleries)
      raise ArgumentError, "Gallery can only be one of: #{GALLERY_FALLBACKS.keys.join(", ")}" unless galleries.all? { valid_gallery?(it) }
      galleries -= available_galleries
      self.available_galleries += galleries
      videos = galleries.delete(:videos)
      if videos
        has_many :videos, as: :record, dependent: :destroy
      end

      galleries.each do |gallery|
        has_many_attached gallery do |attachable|
          VARIANTS.each do |variant, dimensions|
            attachable.variant variant, resize_to_limit: dimensions
          end
        end

        define_method(gallery.to_s.singularize) do |variant: nil, use_fallback: true|
          fallback = use_fallback ? GALLERY_FALLBACKS[gallery] : nil
          if variant
            send(gallery).first&.variant(variant) || fallback
          else
            send(gallery).first || fallback
          end
        end
      end
    end

    private

    def valid_gallery?(gallery)
      GALLERY_FALLBACKS.key?(gallery)
    end
  end
end
