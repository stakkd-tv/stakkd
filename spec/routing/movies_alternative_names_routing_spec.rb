require "rails_helper"

RSpec.describe AlternativeNamesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/movies/1/alternative_names").to route_to("alternative_names#index", movie_id: "1")
    end

    it "routes to #create" do
      expect(post: "/movies/1/alternative_names").to route_to("alternative_names#create", movie_id: "1")
    end

    it "routes to #update" do
      expect(patch: "/movies/1/alternative_names/1").to route_to("alternative_names#update", movie_id: "1", id: "1")
    end
  end
end
