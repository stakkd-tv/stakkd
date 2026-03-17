require "rails_helper"

RSpec.describe "people/index", type: :view do
  before(:each) do
    @p1 = FactoryBot.create(:person, translated_name: "Oscar Piastri", original_name: "Other Name")
    @p2 = FactoryBot.create(:person, translated_name: "Lewis Hamilton", original_name: "Lewis Hamilton")
    assign(:people, Person.all.paginate(page: 1, per_page: 10))
    assign(:people_filter, Filters::People.new({}))
  end

  it "renders a new person link" do
    render
    assert_select "a[href='#{new_person_path}']"
  end

  it "renders a list of people" do
    render
    assert_select "h3", text: "Oscar Piastri (Other Name)"
    assert_select "h3", text: "Lewis Hamilton"
    assert_select "a[href='#{person_path(@p1)}']"
    assert_select "a[href='#{person_path(@p2)}']"
  end
end
