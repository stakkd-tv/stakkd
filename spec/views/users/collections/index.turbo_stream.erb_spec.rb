require "rails_helper"

RSpec.describe "users/collections/index.turbo_stream.erb", type: :view do
  let(:user) { FactoryBot.create(:user) }
  let(:movie) { FactoryBot.create(:movie) }
  let(:query) { Collections::Query.new(user, formats: ["none"], sort: "title") }

  before do
    def view.current_user = nil
    FactoryBot.create(:collection_item, user:, item: movie)
    assign(:user, user)
    assign(:collection_query, query)
    assign(:groups, query.fetch.first)
  end

  it "appends the page's cards to the existing results" do
    render
    assert_select "turbo-stream[action='append'][target='collection_groups']" do
      assert_select "h6", text: movie.translated_title
    end
  end

  context "when there is another page" do
    it "replaces the loader with a lazy frame preserving the filters" do
      assign(:next_page, 3)
      render
      assert_select "turbo-stream[action='replace'][target='load_more_collection_groups']" do
        next_path = user_collection_path(user, **query.to_params, page: 3, format: :turbo_stream)
        assert_select "turbo-frame[loading='lazy'][src=?]", next_path
      end
    end
  end

  context "when the current page is the last page" do
    it "removes the loader" do
      render
      assert_select "turbo-stream[action='remove'][target='load_more_collection_groups']"
    end
  end
end
