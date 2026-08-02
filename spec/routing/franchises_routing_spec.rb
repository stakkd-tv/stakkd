require "rails_helper"

RSpec.describe FranchisesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/franchises").to route_to("franchises#index")
    end

    it "routes to #new" do
      expect(get: "/franchises/new").to route_to("franchises#new")
    end

    it "routes to #show" do
      expect(get: "/franchises/1").to route_to("franchises#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/franchises/1/edit").to route_to("franchises#edit", id: "1")
    end

    it "routes to #create" do
      expect(post: "/franchises").to route_to("franchises#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/franchises/1").to route_to("franchises#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/franchises/1").to route_to("franchises#update", id: "1")
    end

    it "routes to #posters" do
      expect(get: "/franchises/1/posters").to route_to("franchises#posters", id: "1")
    end

    it "routes to #backgrounds" do
      expect(get: "/franchises/1/backgrounds").to route_to("franchises#backgrounds", id: "1")
    end

    it "routes to #logos" do
      expect(get: "/franchises/1/logos").to route_to("franchises#logos", id: "1")
    end

    it "routes to #items" do
      expect(get: "/franchises/1/items").to route_to("franchises#items", id: "1")
    end
  end
end
