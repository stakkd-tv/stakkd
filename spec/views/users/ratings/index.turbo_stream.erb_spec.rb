require "rails_helper"

RSpec.describe "users/ratings/index.turbo_stream.erb", type: :view do
  let(:user) { FactoryBot.create(:user) }
  let(:filters) { {score: "8", hidden_media_types: ["Episode"], hide_dates: "true"} }
  let(:query) { Ratings::Query.new(user, filters) }
  let!(:rating) { FactoryBot.create(:rating, user:, updated_at: Time.zone.local(2026, 11, 20)) }

  def assign_ratings
    ratings, cursor = query.fetch(per_page: 1)
    @next_cursor = cursor
    assign(:ratings, ratings)
    assign(:next_cursor, cursor)
  end

  before do
    def view.current_user = nil
    assign(:user, user)
    assign(:ratings_query, query)
    assign_ratings
  end

  it "appends the batch's poster cards and scores to the existing ratings" do
    render
    assert_select "turbo-stream[action=append][target=rating_items]" do
      assert_select "article#rating_#{rating.id}" do
        assert_select "a", text: rating.item.translated_title
        assert_select "span", text: /8\/10/
      end
    end
  end

  it "removes the loader when the last batch is reached" do
    render
    assert_select "turbo-stream[action=remove][target=load_more_ratings]"
  end

  context "when there is another batch" do
    it "replaces the lazy loader while preserving filters" do
      FactoryBot.create(:rating, user:, updated_at: rating.updated_at - 1.day)
      assign_ratings
      render
      next_path = user_ratings_path(user, **query.to_params, after: @next_cursor, format: :turbo_stream)
      assert_select "turbo-stream[action=replace][target=load_more_ratings]" do
        assert_select "turbo-frame#load_more_ratings[loading=lazy][src=?]", next_path
      end
    end
  end

  it "includes a month heading so the browser can reconcile retained cards across batches" do
    render
    assert_select "[data-rating-month='2026-11-01'] h3", text: "November 2026"
  end
end
