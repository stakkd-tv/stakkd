require "rails_helper"

RSpec.describe "Shows AlternativeNames", type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/shows/1/alternative_names").to route_to("alternative_names#index", show_id: "1")
    end

    it "routes to #create" do
      expect(post: "/shows/1/alternative_names").to route_to("alternative_names#create", show_id: "1")
    end

    it "routes to #update" do
      expect(patch: "/shows/1/alternative_names/1").to route_to("alternative_names#update", show_id: "1", id: "1")
    end
  end
end
