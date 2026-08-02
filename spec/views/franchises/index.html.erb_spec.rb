require "rails_helper"

RSpec.describe "franchises/index", type: :view do
  before(:each) do
    @f1 = FactoryBot.create(:franchise, translated_title: "Back to the Present")
    @f2 = FactoryBot.create(:franchise, translated_title: "Back to the Future")
    filter = ::Filters::Franchises.new({})
    assign(:franchises, filter.filter.paginate(page: 1, per_page: 10))
    assign(:franchise_filter, filter)
  end

  it "renders a new show link" do
    render
    assert_select "a[href='#{new_franchise_path}']"
  end

  it "renders a list of franchises" do
    render
    assert_select "h3", text: "Back to the Present"
    assert_select "h3", text: "Back to the Future"
    assert_select "a[href='#{franchise_path(@f1)}']"
    assert_select "a[href='#{franchise_path(@f2)}']"
  end
end
