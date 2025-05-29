require "rails_helper"

RSpec.describe "people/edit", type: :view do
  let(:person) { FactoryBot.create(:person) }

  before(:each) do
    assign(:person, person)
  end

  it "renders the edit person form" do
    render

    assert_select "form[action='#{person_path(person)}'][method='post']" do
      assert_select "input[name='person[alias]']"
      assert_select "textarea[name='person[biography]']"
      assert_select "select[name='person[gender]']"
      assert_select "input[name='person[imdb_id]']"
      assert_select "select[name='person[known_for]']"
      assert_select "input[name='person[original_name]']"
      assert_select "input[name='person[translated_name]']"
    end
  end
end
