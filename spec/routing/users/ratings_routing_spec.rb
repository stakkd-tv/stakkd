require "rails_helper"

module Users
  RSpec.describe RatingsController, type: :routing do
    describe "routing" do
      it "routes to #index" do
        expect(get: "/users/1/ratings").to route_to("users/ratings#index", user_id: "1")
      end
    end
  end
end
