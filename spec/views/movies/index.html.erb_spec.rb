require "rails_helper"

RSpec.describe "movies/index", type: :view do
  before(:each) do
    @m1 = FactoryBot.create(:movie, translated_title: "Back to the Present")
    @m2 = FactoryBot.create(:movie, translated_title: "Back to the Future")
    assign(:movies, [@m1, @m2])
  end

  it "renders a new movie link" do
    render
    assert_select "a[href='#{new_movie_path}']"
  end

  it "renders a list of movies" do
    render
    assert_select "p", text: "Back to the Present"
    assert_select "p", text: "Back to the Future"
    assert_select "a[href='#{movie_path(@m1)}']"
    assert_select "a[href='#{movie_path(@m2)}']"
  end
end
