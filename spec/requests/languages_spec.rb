require "rails_helper"

RSpec.describe "Languages", type: :request do
  describe "GET /languages" do
    it "renders a successful response" do
      Language.create!(code: "en", translated_name: "English", original_name: "English")
      get languages_url
      expect(response).to be_successful
    end
  end
end
