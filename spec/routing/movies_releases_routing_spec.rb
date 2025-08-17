require "rails_helper"

RSpec.describe ReleasesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/movies/1/releases").to route_to("releases#index", movie_id: "1")
    end

    it "routes to #editor" do
      expect(get: "/movies/1/releases/editor").to route_to("releases#editor", movie_id: "1")
    end

    it "routes to #create" do
      expect(post: "/movies/1/releases").to route_to("releases#create", movie_id: "1")
    end

    it "routes to #update" do
      expect(patch: "/movies/1/releases/1").to route_to("releases#update", movie_id: "1", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/movies/1/releases/1").to route_to("releases#destroy", movie_id: "1", id: "1")
    end
  end
end
