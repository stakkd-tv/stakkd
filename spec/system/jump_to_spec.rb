# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Jump to episode/season", type: :system, js: true do
  before do
    @show = FactoryBot.create(:show)
    @specials = @show.seasons.first
    @season1 = FactoryBot.create(:season, show: @show, number: 1)
    @episode1 = FactoryBot.create(:episode, season: @season1, number: 1)
    @episode2 = FactoryBot.create(:episode, season: @season1, number: 2)
  end

  scenario "jumps to season and episode" do
    visit show_season_path(@show, @specials)
    expect(page).to have_content("Specials")
    expect(page).to have_current_path(show_season_path(@show, @specials))
    select_box = find_all("select[name='jump_to']").first
    select_box.select("Season 1")
    expect(page).to have_current_path(show_season_path(@show, @season1))
    click_link "Episode 1 - Episode 1"
    expect(page).to have_current_path(show_season_episode_path(@show, @season1, @episode1))
    select "Episode 2", from: "jump_to"
    expect(page).to have_current_path(show_season_episode_path(@show, @season1, @episode2))
  end
end
