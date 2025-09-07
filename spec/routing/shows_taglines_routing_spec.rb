require "rails_helper"

RSpec.describe TaglinesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/shows/1/taglines").to route_to("taglines#index", show_id: "1")
    end

    it "routes to #create" do
      expect(post: "/shows/1/taglines").to route_to("taglines#create", show_id: "1")
    end

    it "routes to #update" do
      expect(patch: "/shows/1/taglines/1").to route_to("taglines#update", show_id: "1", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/shows/1/taglines/1").to route_to("taglines#destroy", show_id: "1", id: "1")
    end

    it "routes to #move" do
      expect(post: "/shows/1/taglines/1/move").to route_to("taglines#move", show_id: "1", id: "1")
    end
  end
end
