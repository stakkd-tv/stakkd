require "rails_helper"

RSpec.describe "shows/index", type: :view do
  before(:each) do
    @s1 = FactoryBot.create(:show, translated_title: "Back to the Present")
    @s2 = FactoryBot.create(:show, translated_title: "Back to the Future")
    assign(:shows, Show.all.paginate(page: 1, per_page: 10))
    assign(:tags, [])
    assign(:show_filter, ::Filters::Shows.new({}))
  end

  it "renders a new show link" do
    render
    assert_select "a[href='#{new_show_path}']"
  end

  it "renders a list of shows" do
    render
    assert_select "h3", text: "Back to the Present"
    assert_select "h3", text: "Back to the Future"
    assert_select "a[href='#{show_path(@s1)}']"
    assert_select "a[href='#{show_path(@s2)}']"
  end
end
