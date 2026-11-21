require "rails_helper"

RSpec.describe "users/collections/season.html.erb", type: :view do
  let(:user) { FactoryBot.create(:user) }
  let(:season) { FactoryBot.create(:season) }
  let(:show) { season.show }
  let(:episode) { FactoryBot.create(:episode, season:) }
  let(:query) { Collections::Query.new(user) }
  let(:owner) { nil }

  before do
    viewer = owner
    view.define_singleton_method(:current_user) { viewer }
    entry = FactoryBot.create(:collection_item, user:, item: episode)
    FactoryBot.create(:collection_item_format, collection_item: entry, collection_format: FactoryBot.create(:collection_format, :common))
    assign(:user, user)
    assign(:show, show)
    assign(:season, season)
    assign(:collection_query, query)
    assign(:entries, query.entries_for(show).includes(:formats, item: [:show, :season]).paginate(page: 1))
  end

  it "renders the episode link and its recorded formats" do
    render
    assert_select "turbo-frame#collection_season_#{season.id}" do
      assert_select "a[href=?]", show_season_episode_path(episode, show_id: show, season_id: season), text: "E1 · #{episode.translated_name}"
      assert_select "span", text: "Blu-ray"
      assert_select "button[data-controller='deletion-button']", count: 0
    end
  end

  context "for the owner" do
    let(:owner) { user }

    it "refreshes the collection frame after deleting" do
      render
      assert_select "button[data-deletion-button-refresh-frame-value=?]", "collection_content", text: "Delete"
    end
  end
end
