require "rails_helper"

RSpec.describe CastMembersController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/shows/1/cast_members").to route_to("cast_members#index", show_id: "1")
    end

    it "routes to #create" do
      expect(post: "/shows/1/cast_members").to route_to("cast_members#create", show_id: "1")
    end

    it "routes to #update" do
      expect(patch: "/shows/1/cast_members/1").to route_to("cast_members#update", show_id: "1", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/shows/1/cast_members/1").to route_to("cast_members#destroy", show_id: "1", id: "1")
    end

    it "routes to #move" do
      expect(post: "/shows/1/cast_members/1/move").to route_to("cast_members#move", show_id: "1", id: "1")
    end
  end
end
