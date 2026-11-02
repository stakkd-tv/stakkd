require "rails_helper"

RSpec.describe "users/history/index.turbo_stream.erb", type: :view do
  let(:user) { FactoryBot.create(:user, :confirmed, username: "bob") }
  let(:hidden_media_types) { [] }

  before do
    item = FactoryBot.create(:movie, translated_title: "Amazing movie")
    FactoryBot.create(:history_item, item:, consumed_at: Date.today)
    FactoryBot.create(:history_item, item:, consumed_at: Date.today)
    assign(:user, user)
    assign(:hidden_media_types, hidden_media_types)
    assign(:history_items, HistoryItem.all.includes(:item).paginate(page: 1, per_page: 2))
  end

  it "renders a turbo append with history items" do
    render
    assert_select "turbo-stream[action='append'][target='history_items']" do
      assert_select "p.font-domine", text: "Amazing movie", count: 2
    end
  end

  context "when there is not another page" do
    it "renders a turbo remove for load more" do
      render
      assert_select "turbo-stream[action='remove'][target='load_more_history_items']"
    end
  end

  context "when there is another page" do
    it "renders a load more frame" do
      FactoryBot.create(:history_item, consumed_at: Date.today)
      render
      assert_select "turbo-frame[id='load_more_history_items'][loading='lazy'][src='#{user_history_index_path(user, format: :turbo_stream, last_date: Date.today, page: 2)}']"
    end
  end
end
