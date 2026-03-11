require "rails_helper"

RSpec.describe EpisodesController, type: :routing do
  describe "routing" do
    it "routes to #new" do
      expect(get: "/shows/1/seasons/1/episodes/new").to route_to("episodes#new", season_id: "1", show_id: "1")
    end

    it "routes to #show" do
      expect(get: "/shows/1/seasons/1/episodes/1").to route_to("episodes#show", id: "1", season_id: "1", show_id: "1")
    end

    it "routes to #edit" do
      expect(get: "/shows/1/seasons/1/episodes/1/edit").to route_to("episodes#edit", id: "1", season_id: "1", show_id: "1")
    end

    it "routes to #create" do
      expect(post: "/shows/1/seasons/1/episodes").to route_to("episodes#create", season_id: "1", show_id: "1")
    end

    it "routes to #update via PUT" do
      expect(put: "/shows/1/seasons/1/episodes/1").to route_to("episodes#update", id: "1", season_id: "1", show_id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/shows/1/seasons/1/episodes/1").to route_to("episodes#update", id: "1", season_id: "1", show_id: "1")
    end

    it "routes to #backgrounds" do
      expect(get: "/shows/1/seasons/1/episodes/1/backgrounds").to route_to("episodes#backgrounds", id: "1", season_id: "1", show_id: "1")
    end

    it "routes to #cast" do
      expect(get: "/shows/1/seasons/1/episodes/1/cast").to route_to("episodes#cast", id: "1", season_id: "1", show_id: "1")
    end
  end
end
