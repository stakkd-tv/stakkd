require "rails_helper"

RSpec.describe SeasonsController, type: :routing do
  describe "routing" do
    it "routes to #new" do
      expect(get: "/shows/1/seasons/new").to route_to("seasons#new", show_id: "1")
    end

    it "routes to #show" do
      expect(get: "/shows/1/seasons/1").to route_to("seasons#show", id: "1", show_id: "1")
    end

    it "routes to #edit" do
      expect(get: "/shows/1/seasons/1/edit").to route_to("seasons#edit", id: "1", show_id: "1")
    end

    it "routes to #create" do
      expect(post: "/shows/1/seasons").to route_to("seasons#create", show_id: "1")
    end

    it "routes to #update via PUT" do
      expect(put: "/shows/1/seasons/1").to route_to("seasons#update", id: "1", show_id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/shows/1/seasons/1").to route_to("seasons#update", id: "1", show_id: "1")
    end
  end
end
