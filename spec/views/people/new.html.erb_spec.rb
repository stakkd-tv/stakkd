require "rails_helper"

RSpec.describe "people/new", type: :view do
  before(:each) do
    assign(:person, FactoryBot.build(:person))
  end

  it "renders new person form" do
    render

    assert_select "form[action='#{people_path}'][method='post']" do
      assert_select "input[name='person[alias]']"
      assert_select "textarea[name='person[biography]']"
      assert_select "input[name='person[gender]']"
      assert_select "input[name='person[imdb_id]']"
      assert_select "input[name='person[known_for]']"
      assert_select "input[name='person[original_name]']"
      assert_select "input[name='person[translated_name]']"
    end
  end
end
