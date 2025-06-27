require "rails_helper"

RSpec.describe "movies/_form_nav", type: :view do
  context "when movie is persisted" do
    it "renders the nav" do
      def view.action_name = "edit"
      movie = FactoryBot.create(:movie)
      render "movies/form_nav", movie: movie
      assert_select "a[href='#{edit_movie_path(movie)}'][data-active='true']"
      assert_select "a[href='#{posters_movie_path(movie)}'][data-active='false']"
      assert_select "a[href='#{backgrounds_movie_path(movie)}'][data-active='false']"
      assert_select "a[href='#{logos_movie_path(movie)}'][data-active='false']"
      assert_select "a[href='#{movie_alternative_names_path(movie)}'][data-active='false']"
      assert_select "a[href='#{movie_genre_assignments_path(movie)}'][data-active='false']"
      assert_select "a[href='#{movie_keywords_path(movie)}'][data-active='false']"
      assert_select "a[href='#{movie_company_assignments_path(movie)}'][data-active='false']"
      assert_select "a[href='#{movie_releases_path(movie)}'][data-active='false']"
      assert_select "a[href='#{movie_taglines_path(movie)}'][data-active='false']"
    end
  end

  context "when person is not persisted" do
    it "does not render the nav" do
      movie = FactoryBot.build(:movie)
      render "movies/form_nav", movie: movie
      expect(rendered).to eq ""
    end
  end
end
