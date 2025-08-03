require "rails_helper"

RSpec.describe "Jobs", type: :request do
  describe "GET /jobs" do
    it "renders a successful response" do
      get jobs_url(format: :json)
      expect(response).to be_successful
    end

    context "when there is a query" do
      it "returns a successful response" do
        get jobs_url(query: "query", format: :json)
        expect(response).to be_successful
      end

      it "searches for jobs" do
        job = FactoryBot.create(:job, name: "Random")
        FactoryBot.create(:job, name: "Another")
        get jobs_url(query: job.name, format: :json)
        json = JSON.parse(response.body)
        expect(json).to eq([
          {
            "value" => job.id,
            "label" => job.name,
            "image_url" => nil
          }
        ])
      end
    end
  end
end
