require "rails_helper"

RSpec.describe CompanyAssignmentsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/shows/1/company_assignments").to route_to("company_assignments#index", show_id: "1")
    end

    it "routes to #create" do
      expect(post: "/shows/1/company_assignments").to route_to("company_assignments#create", show_id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/shows/1/company_assignments/1").to route_to("company_assignments#destroy", show_id: "1", id: "1")
    end
  end
end
