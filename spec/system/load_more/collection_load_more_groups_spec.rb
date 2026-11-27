require "rails_helper"

RSpec.feature "Collection load more groups", type: :system, js: true do
  scenario "Loading more appends whole groups and preserves the filters" do
    stub_const("Users::CollectionsController::PER_PAGE", 1)
    user = FactoryBot.create(:user)
    first_movie = FactoryBot.create(:movie, translated_title: "Alpha")
    last_movie = FactoryBot.create(:movie, translated_title: "Zulu")
    collected_show = FactoryBot.create(:show, :with_premiere_date, translated_title: "Middle")
    season = collected_show.seasons_without_specials.first
    second_episode = FactoryBot.create(:episode, season:, number: 2)
    [first_movie, last_movie, season.episodes.find_by!(number: 1), second_episode].each do |item|
      FactoryBot.create(:collection_item, user:, item:)
    end
    filtered_out = FactoryBot.create(:collection_item, user:)
    FactoryBot.create(:collection_item_format, collection_item: filtered_out)

    visit user_collection_path(user, sort: "title", formats: ["none"])

    expect(page).to have_css("#collection_groups h6", text: "Alpha")
    # At desktop width the lazy frame may already have loaded and been removed.
    page.execute_script("document.getElementById('load_more_collection_groups')?.scrollIntoView({ block: 'center' })")
    expect(page).to have_css("#collection_groups h6", text: "Middle")
    expect(page).to have_content("2 matching episodes")
    page.execute_script("document.getElementById('load_more_collection_groups')?.scrollIntoView({ block: 'center' })")

    expect(page).to have_css("#collection_groups h6", text: "Zulu")
    expect(page).to have_css("#collection_groups h6", count: 3)
    expect(page).to have_no_css("turbo-frame#load_more_collection_groups", visible: :all)
  end
end
