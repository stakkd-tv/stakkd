require "rails_helper"

RSpec.describe MoviesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/movies").to route_to("movies#index")
    end

    it "routes to #new" do
      expect(get: "/movies/new").to route_to("movies#new")
    end

    it "routes to #show" do
      expect(get: "/movies/1").to route_to("movies#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/movies/1/edit").to route_to("movies#edit", id: "1")
    end

    it "routes to #create" do
      expect(post: "/movies").to route_to("movies#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/movies/1").to route_to("movies#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/movies/1").to route_to("movies#update", id: "1")
    end

    it "routes to #posters" do
      expect(get: "/movies/1/posters").to route_to("movies#posters", id: "1")
    end

    it "routes to #backgrounds" do
      expect(get: "/movies/1/backgrounds").to route_to("movies#backgrounds", id: "1")
    end

    it "routes to #logos" do
      expect(get: "/movies/1/logos").to route_to("movies#logos", id: "1")
    end
  end
end
