module Videos
  class Source
    def initialize(source_key)
      @source_key = source_key
    end

    def self.for(source, key)
      "Videos::#{source}".constantize.new(key)
    rescue
      new(key)
    end

    def title = nil

    def thumbnail_url = nil

    def video_url = nil

    def icon = "fa-galactic-republic"
  end
end
