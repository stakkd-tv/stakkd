require "rails_helper"

RSpec.describe "Countries", type: :request do
  describe "GET /countries" do
    it "renders a successful response" do
      Country.create!(code: "en", translated_name: "English", original_name: "English")
      get countries_url
      expect(response).to be_successful
    end
  end
end
