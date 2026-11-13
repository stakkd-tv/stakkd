require "rails_helper"

RSpec.describe "users/history/index.html.erb", type: :view do
  let(:scope) { nil }
  let(:user) { FactoryBot.create(:user, :confirmed, username: "bob") }
  let(:current_user) { nil }
  let(:hidden_media_types) { [] }
  let(:show_dates) { false }

  before do
    allow(view).to receive(:params).and_return({controller: "users/history", action: "index"})
    item = FactoryBot.create(:movie, translated_title: "Amazing movie")
    FactoryBot.create(:history_item, user:, item:, consumed_at: Date.today)
    @current_user = current_user
    def view.current_user = @current_user
    assign(:scope, scope)
    assign(:user, user)
    assign(:hidden_media_types, hidden_media_types)
    assign(:history_items, HistoryItem.all.includes(:item).paginate(page: 1, per_page: 1))
    assign(:show_dates, show_dates)
  end

  it "renders a header" do
    render
    assert_select "h4", text: "bob's history"
  end

  it "renders nav links" do
    render
    assert_select "a[data-active='false']", text: "Profile"
    assert_select "a[data-active='true']", text: "History"
    assert_select "a[data-active='false']", text: "Progress"
    assert_select "a[data-active='false']", text: "Collection"
    assert_select "a[data-active='false']", text: "Ratings"
    assert_select "a[data-active='false']", text: "Stacks"
    assert_select "a[data-active='false']", text: "Comments"
    assert_select "a[data-active='false']", text: "Followers"
    assert_select "a[data-active='false']", text: "Following"
  end

  it "renders the hidden media toggle buttons" do
    render
    assert_select "label[data-active='true']", text: "Movies" do
      assert_select "input[name='hidden_media_types[]'][value='Movie'][checked]", count: 0
      assert_select "input[name='hidden_media_types[]'][value='Movie']"
    end

    assert_select "label[data-active='true']", text: "Episodes" do
      assert_select "input[name='hidden_media_types[]'][value='Episode'][checked]", count: 0
      assert_select "input[name='hidden_media_types[]'][value='Episode']"
    end
  end

  it "renders the history items with date headers" do
    render
    assert_select "h3", text: Date.today.strftime("%B %-d, %Y")
    assert_select "h6.font-domine", text: "Amazing movie"
  end

  context "when there is a next page present" do
    before do
      item = FactoryBot.create(:movie, translated_title: "Another movie")
      FactoryBot.create(:history_item, user:, item:, consumed_at: Date.tomorrow)
    end

    it "renders a load more frame" do
      render
      assert_select "turbo-frame[id='load_more_history_items'][loading='lazy'][src='#{user_history_index_path(user, format: :turbo_stream, last_date: Date.today, page: 2)}']"
    end
  end

  context "when movies are hidden" do
    let(:hidden_media_types) { ["Movie"] }

    it "renders the movie toggle in an inactive state" do
      render
      assert_select "label[data-active='false']", text: "Movies" do
        assert_select "input[name='hidden_media_types[]'][value='Movie'][checked]"
      end
    end
  end

  context "when episodes are hidden" do
    let(:hidden_media_types) { ["Episode"] }

    it "renders the episodes toggle in an inactive state" do
      render
      assert_select "label[data-active='false']", text: "Episodes" do
        assert_select "input[name='hidden_media_types[]'][value='Episode'][checked]"
      end
    end
  end

  context "when dates should be shown" do
    let(:show_dates) { true }

    it "renders a hidden form input" do
      render
      assert_select "input[type='hidden'][name='hide_dates'][value='false']"
    end

    it "renders the show dates toggle buttons" do
      render
      assert_select "button[data-active='true']", text: "Show date"
      assert_select "button[data-active='false']", text: "Hide date"
    end
  end

  context "when dates should not be shown" do
    let(:show_dates) { false }

    it "renders a hidden form input" do
      render
      assert_select "input[type='hidden'][name='hide_dates'][value='true']"
    end

    it "renders the show dates toggle buttons" do
      render
      assert_select "button[data-active='false']", text: "Show date"
      assert_select "button[data-active='true']", text: "Hide date"
    end
  end

  context "when the current user is the user being viewed" do
    let(:current_user) { user }

    it "renders a header" do
      render
      assert_select "h4", text: "bob's history", count: 0
      assert_select "h4", text: "Your history"
    end
  end

  context "when there is a scope" do
    let(:scope) { FactoryBot.create(:movie, translated_title: "Avatar") }

    it "renders a header" do
      render
      assert_select "h4", text: "bob's history for Avatar"
    end

    it "replaces the media toggles with the scope name" do
      render
      assert_select "label", text: "Movies", count: 0
      assert_select "label", text: "Episodes", count: 0
      assert_select "label", text: "Avatar"
    end
  end
end
