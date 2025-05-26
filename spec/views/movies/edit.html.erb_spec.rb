require "rails_helper"

RSpec.describe "movies/edit", type: :view do
  let(:movie) {
    Movie.create!(
      budget: "9.99",
      homepage: "MyString",
      imdb_id: "MyString",
      original_title: "MyString",
      overview: "MyString",
      revenue: "9.99",
      runtime: 1,
      status: "MyString",
      tagline: "MyString",
      translated_title: "MyString",
      title_kebab: "MyString"
    )
  }

  before(:each) do
    assign(:movie, movie)
  end

  it "renders the edit movie form" do
    render

    assert_select "form[action=?][method=?]", movie_path(movie), "post" do
      assert_select "input[name=?]", "movie[budget]"

      assert_select "input[name=?]", "movie[homepage]"

      assert_select "input[name=?]", "movie[imdb_id]"

      assert_select "input[name=?]", "movie[original_title]"

      assert_select "input[name=?]", "movie[overview]"

      assert_select "input[name=?]", "movie[revenue]"

      assert_select "input[name=?]", "movie[runtime]"

      assert_select "input[name=?]", "movie[status]"

      assert_select "input[name=?]", "movie[tagline]"

      assert_select "input[name=?]", "movie[translated_title]"

      assert_select "input[name=?]", "movie[title_kebab]"
    end
  end
end
