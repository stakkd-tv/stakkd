require "rails_helper"

RSpec.describe TaglinesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/movies/1/taglines").to route_to("taglines#index", movie_id: "1")
    end

    it "routes to #create" do
      expect(post: "/movies/1/taglines").to route_to("taglines#create", movie_id: "1")
    end

    it "routes to #update" do
      expect(patch: "/movies/1/taglines/1").to route_to("taglines#update", movie_id: "1", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/movies/1/taglines/1").to route_to("taglines#destroy", movie_id: "1", id: "1")
    end

    it "routes to #move" do
      expect(post: "/movies/1/taglines/1/move").to route_to("taglines#move", movie_id: "1", id: "1")
    end
  end
end
