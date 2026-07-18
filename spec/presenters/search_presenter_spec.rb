require "rails_helper"

RSpec.describe SearchPresenter, type: :presenter do
  let(:presenter) { described_class.new(params) }
  let(:params) { {} }

  describe "TABS" do
    it "each tab should have the required values" do
      SearchPresenter::TABS.each do |tab_name, tab|
        expect(tab_name).to be_a Symbol
        expect(tab).to be_a Hash
        expect(tab).to have_key(:klass)
        expect(tab).to have_key(:query_by)
        expect(tab).to have_key(:collection)
        expect(tab).to have_key(:image)
        expect(tab[:image]).to respond_to(:call)
      end
    end
  end

  describe "#multi_search" do
    subject { presenter.multi_search }

    let(:params) { {q: "test"} }

    before do
      # For the sake of this test, we stub the TABS const.
      tabs = {
        movies: {
          klass: Movie,
          query_by: "translated_title,original_title,alternative_names",
          collection: "Movie",
          image: ->(record) { record.poster(variant: :medium) }
        },
        shows: {
          klass: Show,
          query_by: "translated_title,original_title,alternative_names",
          collection: "Show",
          image: ->(record) { record.poster(variant: :medium) }
        }
      }
      stub_const("SearchPresenter::TABS", tabs)
    end

    context "when multi_search fails" do
      before do
        allow(Typesense).to receive(:client).and_raise(StandardError.new("Some error message"))
      end

      it "logs an error" do
        expect(Rails.logger).to receive(:error).with("Failed to execute search for query test: Some error message")
        subject
      end

      it "returns the tabs with empty results" do
        expect(subject).to match_array(
          [
            {tab: "movies", initial_results: [], count: 0},
            {tab: "shows", initial_results: [], count: 0}
          ]
        )
      end
    end

    context "when multi_search succeeds" do
      let(:show) { FactoryBot.create(:show) }
      let(:response) {
        {
          "results" => [
            {"hits" => [], "found" => 0},
            {"hits" => [{"document" => {"id" => show.id}}], "found" => 1}
          ]
        }
      }

      before do
        expected_search_params = {
          searches: [
            {collection: "Movie_test", query_by: "translated_title,original_title,alternative_names"},
            {collection: "Show_test", query_by: "translated_title,original_title,alternative_names"}
          ]
        }
        expected_common_params = {q: "test", per_page: ApplicationController::GLOBAL_PER_PAGE}
        expect(Typesense.client.multi_search).to receive(:perform)
          .with(expected_search_params, expected_common_params)
          .and_return(response)
      end

      context "when there are multiple results for a tab" do
        let(:show2) { FactoryBot.create(:show) }
        let(:response) {
          {
            "results" => [
              {"hits" => [], "found" => 0},
              {"hits" => [{"document" => {"id" => show2.id}}, {"document" => {"id" => show.id}}], "found" => 2}
            ]
          }
        }

        it "orders results based on the order from the search response" do
          shows = subject[0]
          expect(shows[:initial_results]).to eq(
            [
              {aspect: nil, image: "2:3.png", slug: show2.slug, title: show2.to_s},
              {aspect: nil, image: "2:3.png", slug: show.slug, title: show.to_s}
            ]
          )
        end
      end

      it "returns the tabs with results and number of results" do
        expect(subject).to match_array(
          [
            {count: 0, initial_results: [], tab: "movies"},
            {count: 1, initial_results: [{aspect: nil, image: "2:3.png", slug: show.slug, title: show.to_s}], tab: "shows"}
          ]
        )
      end

      it "orders the tabs by the amount of hits each tab has" do
        expect(subject).to eq(
          [
            {count: 1, initial_results: [{aspect: nil, image: "2:3.png", slug: show.slug, title: show.to_s}], tab: "shows"},
            {count: 0, initial_results: [], tab: "movies"}
          ]
        )
      end
    end
  end

  describe "#single_search" do
    subject { presenter.single_search }

    let(:params) { {q: "test", id: tab} }
    let(:tab) { "movies" }

    context "when the search fails" do
      before do
        allow(Movie).to receive(:search).and_raise(StandardError.new("Some error message"))
      end

      it "returns empty results and no more pages" do
        expect(subject).to eq([[], false])
      end

      it "logs an error" do
        expect(Rails.logger).to receive(:error).with("Failed to execute search for query test: Some error message")
        subject
      end
    end

    context "when the search succeeds" do
      before do
        stub_const("ApplicationController::GLOBAL_PER_PAGE", 1)
        @movie1 = FactoryBot.create(:movie)
        @movie2 = FactoryBot.create(:movie)
        allow(Movie).to receive(:search).and_return(Movie.all.paginate(page: 1, per_page: 1))
      end

      context "when no valid tab is given" do
        let(:tab) { "test" }

        it "returns empty results and no more pages" do
          expect(subject).to eq([[], false])
        end
      end

      it "returns results with a boolean for if there are more results" do
        expect(subject).to eq(
          [
            [{aspect: nil, image: "2:3.png", slug: @movie1.slug, title: @movie1.to_s}],
            true
          ]
        )
      end
    end
  end

  describe "#current_tab_valid?" do
    subject { presenter.current_tab_valid? }

    context "when the current tab is valid" do
      let(:params) { {id: "movies"} }

      it { should be_truthy }
    end

    context "when the current tab is not valid" do
      let(:params) { {id: "bogus"} }

      it { should be_falsey }
    end
  end

  describe "#current_page" do
    subject { presenter.current_page }

    context "when page is not specified" do
      let(:params) { {} }

      it { should eq 1 }
    end

    context "when page is specified" do
      let(:params) { {page: "2"} }

      it { should eq 2 }
    end
  end
end
