require "rails_helper"

RSpec.describe GalleriesController, type: :routing do
  describe "routing" do
    it "routes to #posters" do
      expect(get: "/franchises/1/galleries/posters").to route_to("galleries#posters", franchise_id: "1")
    end

    it "routes to #backgrounds" do
      expect(get: "/franchises/1/galleries/backgrounds").to route_to("galleries#backgrounds", franchise_id: "1")
    end

    it "routes to #logos" do
      expect(get: "/franchises/1/galleries/logos").to route_to("galleries#logos", franchise_id: "1")
    end
  end
end
