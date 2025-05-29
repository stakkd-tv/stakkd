require "rails_helper"

RSpec.describe "people/index", type: :view do
  before(:each) do
    @p1 = FactoryBot.create(:person, translated_name: "Oscar Piastri")
    @p2 = FactoryBot.create(:person, translated_name: "Lewis Hamilton")
    assign(:people, [@p1, @p2])
  end

  it "renders a new person link" do
    render
    assert_select "a[href='#{new_person_path}']"
  end

  it "renders a list of people" do
    render
    assert_select "p", text: "Oscar Piastri"
    assert_select "p", text: "Lewis Hamilton"
    assert_select "a[href='#{person_path(@p1)}']"
    assert_select "a[href='#{person_path(@p2)}']"
  end
end
