require "rails_helper"

RSpec.describe "movies/edit", type: :view do
  let(:movie) { FactoryBot.create(:movie) }

  before(:each) do
    assign(:movie, movie)
  end

  it "renders the edit movie form" do
    render

    assert_select "form[action='#{movie_path(movie)}'][method='post']" do
      assert_select "select[name='movie[language_id]']"
      assert_select "select[name='movie[country_id]']"
      assert_select "input[name='movie[original_title]']"
      assert_select "input[name='movie[translated_title]']"
      assert_select "textarea[name='movie[overview]']"
      assert_select "input[name='movie[revenue]']"
      assert_select "select[name='movie[status]']"
      assert_select "input[name='movie[runtime]']"
      assert_select "input[name='movie[revenue]']"
      assert_select "input[name='movie[budget]']"
      assert_select "input[name='movie[homepage]']"
      assert_select "input[name='movie[imdb_id]']"
    end
  end
end
