require "rails_helper"

RSpec.describe SearchController, type: :request do
  describe "GET /search" do
    def perform
      get search_index_path(q:)
    end

    context "when no search query is present" do
      let(:q) { nil }

      it "redirects" do
        perform
        expect(response).to redirect_to(root_path)
      end
    end

    context "when a search query is present" do
      let(:q) { "hello" }

      it "renders a success" do
        expect_any_instance_of(SearchPresenter).to receive(:multi_search).and_return([])
        perform
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "GET /search/:id" do
    let(:results) { double("Results", next_page: nil, any?: false) }

    before do
      allow(results).to receive(:map).and_return([])
    end

    def perform
      get search_path(id: "movies", q:, page: 2, format: :turbo_stream)
    end

    context "when no search query is present" do
      let(:q) { nil }

      it "redirects" do
        perform
        expect(response).to redirect_to(root_path)
      end
    end

    context "when there is a search query" do
      let(:q) { "hello" }

      it "returns http success with turbo stream format" do
        expect(Movie).to receive(:search).with(
          "hello",
          "translated_title,original_title,alternative_names",
          {page: 2, per_page: ApplicationController::GLOBAL_PER_PAGE}
        ).and_return(results)
        perform
        expect(response).to have_http_status(:success)
        expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      end
    end
  end
end
