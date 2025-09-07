require "rails_helper"

RSpec.describe GalleriesController, type: :routing do
  describe "routing" do
    it "routes to #posters" do
      expect(get: "/shows/1/galleries/posters").to route_to("galleries#posters", show_id: "1")
    end

    it "routes to #backgrounds" do
      expect(get: "/shows/1/galleries/backgrounds").to route_to("galleries#backgrounds", show_id: "1")
    end

    it "routes to #logos" do
      expect(get: "/shows/1/galleries/logos").to route_to("galleries#logos", show_id: "1")
    end

    it "routes to #videos" do
      expect(get: "/shows/1/galleries/videos").to route_to("galleries#videos", show_id: "1")
    end
  end
end
