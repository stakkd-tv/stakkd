require "rails_helper"

RSpec.describe CrewMembersController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/movies/1/crew_members").to route_to("crew_members#index", movie_id: "1")
    end

    it "routes to #create" do
      expect(post: "/movies/1/crew_members").to route_to("crew_members#create", movie_id: "1")
    end

    it "routes to #update" do
      expect(patch: "/movies/1/crew_members/1").to route_to("crew_members#update", movie_id: "1", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/movies/1/crew_members/1").to route_to("crew_members#destroy", movie_id: "1", id: "1")
    end
  end
end
