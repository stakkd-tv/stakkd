require "rails_helper"

RSpec.describe "Franchises", type: :request do
  describe "GET /franchises" do
    it "renders a successful response" do
      get shows_url
      expect(response).to be_successful
    end
  end

  describe "GET /franchises/:id" do
    it "renders a successful response" do
      franchise = FactoryBot.create(:franchise)
      get franchise_path(franchise)
      expect(response).to be_successful
    end
  end
end
