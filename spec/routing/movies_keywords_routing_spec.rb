require "rails_helper"

RSpec.describe KeywordsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/movies/1/keywords").to route_to("keywords#index", movie_id: "1")
    end

    it "routes to #create" do
      expect(post: "/movies/1/keywords").to route_to("keywords#create", movie_id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/movies/1/keywords/1").to route_to("keywords#destroy", movie_id: "1", id: "1")
    end
  end
end
