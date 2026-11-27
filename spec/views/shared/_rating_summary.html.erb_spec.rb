require "rails_helper"

RSpec.describe "shared/_rating_summary", type: :view do
  it "formats one decimal place and a delimited vote count" do
    record = double(average_rating: BigDecimal("8.25"), ratings_count: 1234)
    render partial: "shared/rating_summary", locals: {record:}

    assert_select "[aria-label='Community rating']" do
      assert_select "span.font-fugaz", text: "8.3"
      assert_select "span", text: "Community · 1,234 ratings"
    end
  end

  it "renders nothing for an unrated record" do
    record = double(average_rating: nil, ratings_count: 0)
    render partial: "shared/rating_summary", locals: {record:}

    expect(rendered.strip).to be_empty
  end
end
