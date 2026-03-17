require "rails_helper"

RSpec.describe CrewMembersController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/shows/1/seasons/1/episodes/1/crew-members").to route_to("crew_members#index", show_id: "1", season_id: "1", episode_id: "1")
    end

    it "routes to #create" do
      expect(post: "/shows/1/seasons/1/episodes/1/crew-members").to route_to("crew_members#create", show_id: "1", season_id: "1", episode_id: "1")
    end

    it "routes to #update" do
      expect(patch: "/shows/1/seasons/1/episodes/1/crew-members/1").to route_to("crew_members#update", show_id: "1", season_id: "1", episode_id: "1", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/shows/1/seasons/1/episodes/1/crew-members/1").to route_to("crew_members#destroy", show_id: "1", season_id: "1", episode_id: "1", id: "1")
    end
  end
end
