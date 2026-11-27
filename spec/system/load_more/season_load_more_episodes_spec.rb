# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Season load more episodes", type: :system, js: true do
  scenario "Scrolling to each episode loader appends episodes with the user's episode state" do
    stub_const("SeasonsController::EPISODES_PER_PAGE", 1)
    user = FactoryBot.create(:user, :confirmed)
    season = FactoryBot.create(:season)
    FactoryBot.create(:episode, season:, number: 1, translated_name: "Pilot")
    episode = FactoryBot.create(:episode, season:, number: 2, translated_name: "Second episode")
    FactoryBot.create(:episode, season:, number: 3, translated_name: "Third episode")
    FactoryBot.create(:history_item, user:, item: episode, consumed_at: 1.day.ago)
    FactoryBot.create(:stack_item, stack: user.watchlist!, item: episode)
    # Keep lazy loaders below the viewport without switching to the mobile layout.
    page.current_window.resize_to(1920, 500)

    sign_in user
    visit show_season_path(season, show_id: season.show)

    expect(page).to have_css("#season_episodes a.font-domine", text: "Episode 1 - Pilot")
    expect(page).to have_no_css("#season_episodes a.font-domine", text: "Episode 2 - Second episode", wait: 0)
    scroll_to find("turbo-frame#load_more_episodes", visible: :all), align: :center

    expect(page).to have_css("#season_episodes a.font-domine", text: "Episode 2 - Second episode")
    expect(page).to have_css("#season_episodes a.font-domine", text: "Episode 1 - Pilot")
    episode_path = show_season_episode_path(episode, season_id: season, show_id: season.show)
    expect(page).to have_css("#season_episodes button[data-record-type='Episode'][data-record-id='#{episode.id}'][data-status='completed']")
    expect(page).to have_css("#season_episodes a[href='#{episode_path}'] i.fa-solid.fa-bookmark")

    page_three_path = show_season_path(season, show_id: season.show, page: 3, format: :turbo_stream)
    next_loader = find("turbo-frame#load_more_episodes[src='#{page_three_path}']", visible: :all)
    expect(page).to have_no_css("#season_episodes a.font-domine", text: "Episode 3 - Third episode", wait: 0)
    scroll_to next_loader, align: :center

    expect(page).to have_css("#season_episodes a.font-domine", text: "Episode 3 - Third episode")
    expect(page).to have_css("#season_episodes a.font-domine", count: 3)
    expect(page).to have_no_css("turbo-frame#load_more_episodes", visible: :all)
  end
end
