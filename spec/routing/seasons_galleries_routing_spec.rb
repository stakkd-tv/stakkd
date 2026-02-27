require "rails_helper"

RSpec.describe GalleriesController, type: :routing do
  describe "routing" do
    it "routes to #posters" do
      expect(get: "/shows/1/seasons/1/galleries/posters").to route_to("galleries#posters", show_id: "1", season_id: "1")
    end
  end
end
