RSpec.shared_examples "an inline rating picker" do
  it "renders the supplied personal score in the ten-star picker" do
    allow(view).to receive(:authenticated?).and_return(true)
    def view.current_user = FactoryBot.build_stubbed(:user)
    assign(:rating_scores, {rating_record => 8})

    expect(Manage::Ratings).not_to receive(:new)
    render

    path = view.polymorphic_record_path(rating_record, "set_rating")
    assert_select "[data-rating-url-value='#{path}']" do
      assert_select "button[data-rating-target='star']", count: 10
      assert_select "button[data-score='8'][aria-pressed='true']", count: 1
      assert_select "button[data-filled='true']", count: 8
    end
  end
end

RSpec.shared_examples "an image rating button" do
  it "renders the supplied personal score over the linked image" do
    allow(view).to receive(:authenticated?).and_return(true)
    def view.current_user = FactoryBot.build_stubbed(:user)
    assign(:rating_scores, {rating_record => 8})

    expect(Manage::Ratings).not_to receive(:new)
    render

    path = view.polymorphic_record_path(rating_record, "set_rating")
    assert_select "a:has(img) + button[data-rating-button-url-value='#{path}'][data-rated='true']" do
      assert_select "[data-rating-button-target='badgeScore']", text: "8"
    end
  end
end
