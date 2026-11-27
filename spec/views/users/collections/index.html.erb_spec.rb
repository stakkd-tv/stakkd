require "rails_helper"

RSpec.describe "users/collections/index.html.erb", type: :view do
  let(:user) { FactoryBot.create(:user) }
  let(:query) { Collections::Query.new(user) }

  before do
    allow(view).to receive(:params).and_return({controller: "users/collections", action: "index"})
    view.define_singleton_method(:current_user) { @user }
    assign(:user, user)
    assign(:collection_query, query)
    assign(:formats, CollectionFormat.available_to(user).order(:name))
    assign(:groups, [])
  end

  it "renders navigation with only Collection active" do
    render
    assert_select "a[data-active='true'][href=?]", user_collection_path(user), text: "Collection"
    %w[Profile History Progress Watchlist Ratings Stacks Comments Followers Following].each do |label|
      assert_select "a[data-active='false']", text: label
    end
  end

  context "with collection groups" do
    it "renders cards and the filter controls in the collection frame" do
      movie = FactoryBot.create(:movie)
      FactoryBot.create(:collection_item, user:, item: movie)
      assign(:groups, query.fetch.first)
      render

      assert_select "turbo-frame#collection_content" do
        assert_select "select[name='formats[]'][multiple][data-controller='slim-select']"
        assert_select "select[name='sort'][data-slim-select-searchable-value='false']"
        assert_select "#collection_movie_#{movie.id} h6", text: movie.translated_title
      end
    end
  end

  context "without collection groups" do
    before { assign(:groups, []) }

    it "renders the empty collection message" do
      render
      expect(rendered).to include("No items in this collection yet.")
    end

    context "with an active filter" do
      let(:query) { Collections::Query.new(user, formats: ["none"]) }

      it "renders the no matches message" do
        render
        expect(rendered).to include("No collection items match these filters.")
      end
    end
  end
end
