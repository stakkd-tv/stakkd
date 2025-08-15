module Galleries
  class Presenter
    include Rails.application.routes.url_helpers

    ASPECT_HASH_MAP = {
      posters: "min-w-40 max-w-40 aspect-2/3",
      images: "min-w-40 max-w-40 aspect-2/3",
      logos: "min-w-60 max-w-60 aspect-square",
      backgrounds: "min-w-[425px] max-w-[425px] aspect-16/9",
      videos: "min-w-[425px] max-w-[425px] aspect-16/9"
    }

    MAX_IMAGES = {
      posters: 5,
      images: 5,
      logos: 5,
      backgrounds: 3,
      videos: 3
    }

    PARTIALS = {
      videos: "shared/video_gallery"
    }

    def initialize(record)
      @record = record
    end

    def tabs
      available_galleries.map do |image_type|
        max_images = MAX_IMAGES[image_type]
        images = @record.send(image_type)
        {
          name: image_type.to_s.humanize,
          images: images.take(max_images),
          aspect: ASPECT_HASH_MAP[image_type],
          show_view_more: images.size > max_images,
          view_more_path: view_more_path(image_type),
          partial: PARTIALS[image_type] || "shared/gallery"
        }
      end
    end

    private

    def available_galleries = @record.respond_to?(:available_galleries) ? @record.available_galleries : []

    def view_more_path(image_type)
      record_type = @record.class.name.underscore
      send("#{image_type}_#{record_type}_galleries_path", @record)
    rescue
      ""
    end
  end
end
