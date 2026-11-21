require "rails_helper"

RSpec.describe "users/collections/show.html.erb", type: :view do
  let(:user) { FactoryBot.create(:user) }
  let(:show) { FactoryBot.create(:show, :with_premiere_date) }
  let(:season) { show.seasons_without_specials.first }
  let(:query) { Collections::Query.new(user) }

  before do
    def view.current_user = nil
    assign(:user, user)
    assign(:show, show)
    assign(:seasons, [season])
    assign(:collection_query, query)
    assign(:active_format_names, [])
    assign(:owned_counts, season.id => 1)
    assign(:eligible_counts, season.id => 2)
  end

  it "links to the show and lazy loads the season with ownership counts" do
    render

    assert_select "h4 a[href=?]", show_path(show), text: show.translated_title
    assert_select "a[href=?]", show_path(show), text: "View show"
    assert_select "summary", text: /1 of 2 episodes owned/
    assert_select "turbo-frame[loading='lazy'][src=?]",
      user_collection_season_path(user, show, season.number, **query.to_params)
    assert_select "button[data-controller='deletion-button']", count: 0
  end

  context "with an active format filter" do
    let(:query) { Collections::Query.new(user, formats: ["none"]) }

    it "shows the active filter and passes it into the season frame" do
      assign(:active_format_names, ["No format specified"])
      render

      assert_select "span", text: "No format specified"
      assert_select "summary", text: /1 matching episode/
      assert_select "turbo-frame[src=?]",
        user_collection_season_path(user, show, season.number, **query.to_params)
    end
  end
end
