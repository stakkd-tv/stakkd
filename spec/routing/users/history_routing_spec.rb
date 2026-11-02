require "rails_helper"

module Users
  RSpec.describe HistoryController, type: :routing do
    describe "routing" do
      it "routes to #index" do
        expect(get: "/users/1/history").to route_to("users/history#index", user_id: "1")
      end
    end
  end
end
