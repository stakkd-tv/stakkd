require "rails_helper"

RSpec.feature "Collection load more episodes", type: :system, js: true do
  scenario "Paging episodes preserves the show and the selected formats" do
    stub_const("Users::CollectionsController::EPISODES_PER_PAGE", 1)
    user = FactoryBot.create(:user)
    season = FactoryBot.create(:season)
    bluray = FactoryBot.create(:collection_format, :common)
    selected = [FactoryBot.create(:episode, season:, number: 1, translated_name: "Pilot"),
      FactoryBot.create(:episode, season:, number: 3, translated_name: "Finale")]
    selected.each do |item|
      entry = FactoryBot.create(:collection_item, user:, item:)
      FactoryBot.create(:collection_item_format, collection_item: entry, collection_format: bluray)
    end
    FactoryBot.create(:collection_item, user:, item: FactoryBot.create(:episode, season:, number: 2))

    visit user_collection_show_path(user, season.show, formats: [bluray.id])

    scroll_to find("#collection_season_#{season.id}"), align: :center
    within("#collection_season_#{season.id}") do
      expect(page).to have_link("E1 · Pilot")
      click_link "More episodes"
      expect(page).to have_link("E3 · Finale")
      expect(page).to have_no_link("More episodes")
      click_link "Previous episodes"
      expect(page).to have_link("E1 · Pilot")
    end
    expect(page).to have_current_path(user_collection_show_path(user, season.show, formats: [bluray.id]))
  end

  scenario "Deleting an episode draws the next episode onto the first page and refreshes counts" do
    stub_const("Users::CollectionsController::EPISODES_PER_PAGE", 2)
    user = FactoryBot.create(:user, :confirmed)
    season = FactoryBot.create(:season)
    ["Pilot", "Second episode", "Finale"].each_with_index do |name, index|
      item = FactoryBot.create(:episode, season:, number: index + 1, translated_name: name)
      FactoryBot.create(:collection_item, user:, item:)
    end

    sign_in user
    visit user_collection_show_path(user, season.show)
    frame = "#collection_season_#{season.id}"
    scroll_to find(frame), align: :center
    within(frame) do
      expect(page).to have_link("More episodes")
      expect(page).to have_no_link("E3 · Finale")
      find('button[aria-label="More options for Pilot"]').click
      within(".collection_episode_#{season.episodes.find_by!(number: 1).id}_options") do
        click_button "Delete"
      end
    end
    within("dialog[open]") { click_button "Yes" }

    within(frame) do
      expect(page).to have_link("E3 · Finale")
      expect(page).to have_no_link("E1 · Pilot")
      expect(page).to have_no_link("More episodes")
    end
    expect(page).to have_css("summary", text: /2 of 3 episodes owned/)
    find('button[aria-label="More options for Season 1"]').click
    within(".collection_season_#{season.id}_options") { click_button "Delete" }
    within("dialog[open]") { expect(page).to have_content("2 owned episodes will be removed") }
  end
end
