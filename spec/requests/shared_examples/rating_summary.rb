RSpec.shared_examples "a media page with a rating summary" do |summary_count|
  def rating_summary_path
    public_send("#{record.route_name}_path", record.records_for_polymorphic_paths)
  end

  it "shows the rounded average and vote count to guests without contributor identities" do
    public_user = FactoryBot.create(:user)
    private_user = FactoryBot.create(:user, private: true)
    FactoryBot.create(:rating, item: record, user: public_user, score: 7)
    FactoryBot.create(:rating, item: record, user: private_user, score: 10)
    FactoryBot.create(:rating, item: record, score: 8)

    get rating_summary_path

    expect(response).to have_http_status(:ok)
    assert_select "[aria-label='Community rating']", count: summary_count do
      assert_select "span.font-fugaz", text: "8.3", count: summary_count
      assert_select "span", text: "Community · 3 ratings", count: summary_count
    end
    expect(response.body).not_to include(public_user.username, private_user.username, private_user.email_address)
  end

  it "hides the summary when there are no votes" do
    get rating_summary_path

    expect(response).to have_http_status(:ok)
    assert_select "[aria-label='Community rating']", count: 0
  end

  it "reflects a single vote, replacement and removal on the next page load" do
    user = FactoryBot.create(:user)
    manager = Manage::Ratings.new(user)
    manager.set!(record, score: 9)
    get rating_summary_path
    assert_select "[aria-label='Community rating'] span.font-fugaz", text: "9.0", count: summary_count
    assert_select "[aria-label='Community rating'] span", text: "Community · 1 rating", count: summary_count

    manager.set!(record, score: 6)
    get rating_summary_path
    assert_select "[aria-label='Community rating'] span.font-fugaz", text: "6.0", count: summary_count
    assert_select "[aria-label='Community rating'] span", text: "Community · 1 rating", count: summary_count

    manager.remove!(record)
    get rating_summary_path
    assert_select "[aria-label='Community rating']", count: 0
  end
end
