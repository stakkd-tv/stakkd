RSpec.shared_examples "an inline rating picker" do
  it "passes a false rateable value to Stimulus when the release date is unknown" do
    allow(view).to receive(:authenticated?).and_return(true)
    def view.current_user = FactoryBot.build_stubbed(:user)
    allow(rating_record).to receive(:released?).and_return(nil)
    assign(:rating_scores, {rating_record => 8})

    render

    path = view.polymorphic_record_path(rating_record, "set_rating")
    assert_select "[data-rating-url-value='#{path}'][data-rating-rateable-value=false]" do
      assert_select "button[data-score='8']:not([disabled])"
      assert_select "button[data-score='9'][disabled]"
    end
  end

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
  it "allows removal of a saved rating when the release date is unknown" do
    allow(view).to receive(:authenticated?).and_return(true)
    def view.current_user = FactoryBot.build_stubbed(:user)
    date_column = case rating_record
    when Movie then :release_date
    when Episode then :original_air_date
    else :premiere_date
    end
    rating_record.update_columns(date_column => nil)
    assign(:rating_scores, {rating_record => 8})

    render

    path = view.polymorphic_record_path(rating_record, "set_rating")
    assert_select "button[data-rating-button-url-value='#{path}'][data-rating-button-rateable-value=false]:not([disabled])"
  end

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
