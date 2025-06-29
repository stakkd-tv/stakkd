module Videos
  class Vimeo < Source
    def title
      video.try(:[], "title")
    end

    def thumbnail_url
      video.try(:[], "thumbnail_large")
    end

    def video_url
      "https://vimeo.com/#{@source_key}"
    end

    def icon = "fa-vimeo"

    private

    def response
      @response ||= ::Vimeo::Simple::Video.info(@source_key)
    end

    def video
      @video ||= response.is_a?(Array) ? response.first : nil
    end
  end
end
