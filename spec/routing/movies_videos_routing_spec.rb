require "rails_helper"

RSpec.describe VideosController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/movies/1/videos").to route_to("videos#index", movie_id: "1")
    end

    it "routes to #create" do
      expect(post: "/movies/1/videos").to route_to("videos#create", movie_id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/movies/1/videos/1").to route_to("videos#destroy", movie_id: "1", id: "1")
    end
  end
end
