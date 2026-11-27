require "rails_helper"

RSpec.describe "users/ratings/index.html.erb", type: :view do
  let(:user) { FactoryBot.create(:user, username: "bob") }
  let(:current_user) { nil }
  let(:filters) { {} }
  let(:query) { Ratings::Query.new(user, filters) }
  let(:per_page) { 24 }
  let!(:rating) { FactoryBot.create(:rating, user:, updated_at: Time.zone.local(2026, 11, 20)) }

  def assign_ratings
    ratings, cursor = query.fetch(per_page:)
    @next_cursor = cursor
    assign(:ratings, ratings)
    assign(:next_cursor, cursor)
  end

  before do
    allow(view).to receive(:params).and_return({controller: "users/ratings", action: "index"}.merge(filters))
    def view.current_user = @current_user
    assign(:current_user, current_user)
    assign(:user, user)
    assign(:ratings_query, query)
    assign_ratings
  end

  it "renders the profile owner's heading" do
    render
    assert_select "h4", text: "bob's ratings"
  end

  it "renders navigation with only Ratings active" do
    render
    assert_select "a[data-active='true'][href=?]", user_ratings_path(user), text: "Ratings"
    %w[Profile History Progress Watchlist Collection Stacks Comments Followers Following].each do |label|
      assert_select "a[data-active='false']", text: label
    end
  end

  it "renders the labelled media toggles, exact score choices and sorting options" do
    render
    Rating::ITEM_TYPES.each do |type|
      assert_select "label[data-active='true']", text: type.pluralize do
        assert_select "input[name='hidden_media_types[]'][value=?]:not([checked])", type
      end
    end
    assert_select "input[type=radio][name=score]", count: 11
    assert_select "input[name=score][value=''][checked]"
    assert_select "select[name=sort][data-controller=slim-select]" do
      Ratings::Query::SORTS.each do |value, config|
        assert_select "option[value=?]", value, text: config.fetch(:label)
      end
    end
  end

  it "renders linked poster cards and read-only scores for visitors" do
    render
    assert_select "article#rating_#{rating.id}" do
      assert_select "a[href=?] img", movie_path(rating.item)
      assert_select "a", text: rating.item.translated_title
      assert_select "span", text: /8\/10/
      assert_select "button[data-controller=rating-button]", count: 0
    end
  end

  it "renders month headings and date controls" do
    render
    assert_select "#rating_items[data-show-dates=true] h3", text: "November 2026"
    assert_select "button[data-active=true]", text: "Show dates"
    assert_select "button[data-active=false]", text: "Hide dates"
  end

  it "keeps the filters outside the results loading frame" do
    render
    assert_select "form[data-turbo-frame=ratings_content]"
    assert_select "turbo-frame#ratings_content" do
      assert_select "article", count: 1
      assert_select "form", count: 0
    end
  end

  it "renders show, season and episode context through their cards" do
    episode = FactoryBot.create(:episode, translated_name: "The Crossing")
    [episode, episode.season, episode.show].each { |item| FactoryBot.create(:rating, user:, item:) }
    assign_ratings
    render
    assert_select "#rating_items article", count: 4
    assert_select "#rating_items p", text: "Show"
    assert_select "#rating_items p", text: "Season 1"
    assert_select "#rating_items p", text: "S1E1 · The Crossing"
  end

  context "when the profile owner is signed in" do
    let(:current_user) { user }

    it "renders the owner's heading and editable rating badge" do
      render
      assert_select "h4", text: "Your ratings"
      assert_select "article#rating_#{rating.id} button[data-controller=rating-button][data-rating-button-url-value=?][data-rating-button-score-value='8']", set_rating_movie_path(rating.item)
    end

    it "permits removal of an existing rating when the release date is unknown" do
      rating.item.update_columns(release_date: nil)
      assign_ratings
      render
      assert_select "article#rating_#{rating.id} button[data-rating-button-rateable-value=false]:not([disabled])"
    end
  end

  context "with selected filters" do
    let(:filters) { {hidden_media_types: ["Show"], score: "8"} }

    it "renders the selected media and score state" do
      render
      assert_select "label[data-active=false]", text: "Shows" do
        assert_select "input[value=Show][checked]"
      end
      assert_select "input[name=score][value='8'][checked]"
      assert_select "input[name=score][value='']:not([checked])"
    end
  end

  context "with dates hidden" do
    let(:filters) { {hide_dates: "true"} }

    it "renders the hidden date preference" do
      render
      assert_select "#rating_items[data-show-dates=false]"
      assert_select "input[name=hide_dates][value=true]"
      assert_select "button[data-active=true]", text: "Hide dates"
    end
  end

  context "with a score sort" do
    let(:filters) { {sort: "highest"} }

    it "renders a continuous grid and hides the date controls" do
      render
      assert_select "#rating_items h3", count: 0
      assert_select "[data-ratings-controls-target=dates][hidden]"
      assert_select "option[value=highest][selected]"
    end
  end

  context "with oldest ratings first" do
    let(:filters) { {sort: "oldest"} }

    it "renders month headings in chronological order" do
      FactoryBot.create(:rating, user:, updated_at: Time.zone.local(2026, 10, 20))
      assign_ratings
      render
      assert_select "#rating_items h3" do |headings|
        expect(headings.map(&:text)).to eq(["October 2026", "November 2026"])
      end
    end
  end

  context "with another batch" do
    let(:per_page) { 1 }

    it "renders a lazy loader preserving the selected filters" do
      FactoryBot.create(:rating, user:, updated_at: rating.updated_at - 1.day)
      assign_ratings
      render
      next_path = user_ratings_path(user, **query.to_params, after: @next_cursor, format: :turbo_stream)
      assert_select "turbo-frame#load_more_ratings[loading=lazy][src=?]", next_path
    end
  end

  context "without ratings" do
    before do
      rating.destroy!
      assign_ratings
    end

    it "renders the empty profile message" do
      render
      expect(rendered).to include("No ratings yet.")
      assert_select "turbo-frame#load_more_ratings", count: 0
    end
  end

  context "without matching ratings" do
    let(:filters) { {score: "1"} }

    it "renders the empty filter message" do
      render
      expect(rendered).to include("No ratings match these filters.")
    end
  end
end
