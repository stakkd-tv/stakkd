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
end
