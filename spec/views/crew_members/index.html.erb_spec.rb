require "rails_helper"

RSpec.describe "crew_members/index", type: :view do
  let(:relatable) { FactoryBot.create(:movie) }

  before(:each) do
    assign(:relatable, relatable)
    assign(:table_presenter, Tabulator::CrewMembersPresenter.new(relatable.crew_members))

    def view.relatable_model_plural = "movies"

    def view.nested_path_for(relatable:) = movie_crew_members_path(relatable)
  end

  it "renders the table editor" do
    render
    assert_select "div[data-controller='table-editor']"
    assert_select "div[data-table-editor-path-prefix-value='#{movie_crew_members_path(relatable)}']"
    assert_select "div[data-table-editor-model-name-value='crew_member']"
  end

  context "when relatable is a movie" do
    let(:relatable) { FactoryBot.create(:movie) }

    before do
      def view.relatable_model_plural = "movies"

      def view.nested_path_for(relatable:) = movie_crew_members_path(relatable)
    end

    it "renders the new crew member form" do
      render
      assert_select "form[action='#{movie_crew_members_path(relatable)}']" do
        assert_select "input[name='crew_member[person_id]']"
        assert_select "input[name='crew_member[job_id]']"
      end
    end
  end

  context "when relatable is a show" do
    let(:relatable) { FactoryBot.create(:show) }

    before do
      def view.relatable_model_plural = "shows"

      def view.nested_path_for(relatable:) = show_crew_members_path(relatable)
    end

    it "renders the new crew member form" do
      render
      assert_select "form[action='#{show_crew_members_path(relatable)}']" do
        assert_select "input[name='crew_member[person_id]']"
        assert_select "input[name='crew_member[job_id]']"
      end
    end
  end

  context "when relatable is an episode" do
    let(:relatable) { FactoryBot.create(:episode) }

    before do
      def view.relatable_model_plural = "episodes"

      def view.nested_path_for(relatable:) = show_season_episode_crew_members_path(relatable.show, relatable.season, relatable)
    end

    it "renders the new crew member form" do
      render
      assert_select "form[action='#{show_season_episode_crew_members_path(relatable.show, relatable.season, relatable)}']" do
        assert_select "input[name='crew_member[person_id]']"
        assert_select "input[name='crew_member[job_id]']"
      end
    end
  end
end
