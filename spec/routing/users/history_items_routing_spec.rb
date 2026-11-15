require "rails_helper"

module Users
  RSpec.describe HistoryItemsController, type: :routing do
    describe "routing" do
      it "routes to #destroy" do
        expect(delete: "/users/1/history_items/1").to route_to("users/history_items#destroy", user_id: "1", id: "1")
      end
    end
  end
end
