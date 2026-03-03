require "rails_helper"

RSpec.describe SeasonRegularsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/shows/1/seasons/1/season_regulars").to route_to("season_regulars#index", show_id: "1", season_id: "1")
    end

    it "routes to #create" do
      expect(post: "/shows/1/seasons/1/season_regulars").to route_to("season_regulars#create", show_id: "1", season_id: "1")
    end

    it "routes to #update" do
      expect(patch: "/shows/1/seasons/1/season_regulars/1").to route_to("season_regulars#update", show_id: "1", season_id: "1", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/shows/1/seasons/1/season_regulars/1").to route_to("season_regulars#destroy", show_id: "1", season_id: "1", id: "1")
    end

    it "routes to #move" do
      expect(post: "/shows/1/seasons/1/season_regulars/1/move").to route_to("season_regulars#move", show_id: "1", season_id: "1", id: "1")
    end
  end
end
