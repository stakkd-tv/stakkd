require "rails_helper"

RSpec.describe GuestStarsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/shows/1/seasons/1/episodes/1/guest-stars").to route_to("guest_stars#index", show_id: "1", season_id: "1", episode_id: "1")
    end

    it "routes to #create" do
      expect(post: "/shows/1/seasons/1/episodes/1/guest-stars").to route_to("guest_stars#create", show_id: "1", season_id: "1", episode_id: "1")
    end

    it "routes to #update" do
      expect(patch: "/shows/1/seasons/1/episodes/1/guest-stars/1").to route_to("guest_stars#update", show_id: "1", season_id: "1", episode_id: "1", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/shows/1/seasons/1/episodes/1/guest-stars/1").to route_to("guest_stars#destroy", show_id: "1", season_id: "1", episode_id: "1", id: "1")
    end

    it "routes to #move" do
      expect(post: "/shows/1/seasons/1/episodes/1/guest-stars/1/move").to route_to("guest_stars#move", show_id: "1", season_id: "1", episode_id: "1", id: "1")
    end
  end
end
