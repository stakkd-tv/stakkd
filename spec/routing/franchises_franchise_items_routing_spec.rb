require "rails_helper"

RSpec.describe FranchiseItemsController, type: :routing do
  describe "routing" do
    it "routes to #editor" do
      expect(get: "/franchises/1/items/editor").to route_to("franchise_items#editor", franchise_id: "1")
    end

    it "routes to #create" do
      expect(post: "/franchises/1/items").to route_to("franchise_items#create", franchise_id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/franchises/1/items/1").to route_to("franchise_items#destroy", franchise_id: "1", id: "1")
    end
  end
end
