require "rails_helper"

RSpec.describe "shows/edit", type: :view do
  let(:show) { FactoryBot.create(:show) }

  before(:each) do
    assign(:show, show)
  end

  it "renders the edit show form" do
    render

    assert_select "form[action='#{show_path(show)}'][method='post']" do
      assert_select "select[name='show[language_id]']"
      assert_select "select[name='show[country_id]']"
      assert_select "input[name='show[original_title]']"
      assert_select "input[name='show[translated_title]']"
      assert_select "textarea[name='show[overview]']"
      assert_select "select[name='show[status]']"
      assert_select "select[name='show[type]']"
      assert_select "input[name='show[homepage]']"
      assert_select "input[name='show[imdb_id]']"
    end
  end
end
