require "rails_helper"

RSpec.describe VideosController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/shows/1/videos").to route_to("videos#index", show_id: "1")
    end

    it "routes to #create" do
      expect(post: "/shows/1/videos").to route_to("videos#create", show_id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/shows/1/videos/1").to route_to("videos#destroy", show_id: "1", id: "1")
    end
  end
end
