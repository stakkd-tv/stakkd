require "rails_helper"

RSpec.describe KeywordsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/shows/1/keywords").to route_to("keywords#index", show_id: "1")
    end

    it "routes to #create" do
      expect(post: "/shows/1/keywords").to route_to("keywords#create", show_id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/shows/1/keywords/1").to route_to("keywords#destroy", show_id: "1", id: "1")
    end
  end
end
