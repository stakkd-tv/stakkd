require "rails_helper"

module Users
  RSpec.describe StackItemsController, type: :routing do
    describe "routing" do
      it "routes to #destroy" do
        expect(delete: "/users/1/stacks/1/stack_items/1").to route_to("users/stack_items#destroy", user_id: "1", stack_id: "1", id: "1")
      end
    end
  end
end
