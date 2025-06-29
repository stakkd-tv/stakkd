require "google/apis/youtube_v3"

module Videos
  class YouTube < Source
    def title
      video&.snippet&.title
    end

    def thumbnail_url
      video&.snippet&.thumbnails&.maxres&.url
    end

    def video_url
      "https://www.youtube.com/watch?v=#{@source_key}"
    end

    def icon = "fa-youtube"

    private

    def youtube_api_client
      @youtube_api_client ||= Google::Apis::YoutubeV3::YouTubeService.new.tap do |client|
        client.key = Rails.application.credentials.dig(:youtube_api_key)
      end
    end

    def response
      @response ||= youtube_api_client.list_videos("snippet", id: @source_key)
    rescue
      @response = nil
    end

    def video
      @video ||= response&.items&.first
    end
  end
end
