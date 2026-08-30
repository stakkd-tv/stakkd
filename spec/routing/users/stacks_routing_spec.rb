require "rails_helper"

module Users
  RSpec.describe StacksController, type: :routing do
    describe "routing" do
      it "routes to #index" do
        expect(get: "/users/1/stacks").to route_to("users/stacks#index", user_id: "1")
      end
    end
  end
end
