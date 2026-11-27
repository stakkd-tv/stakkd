require "rails_helper"

RSpec.describe "Collection browsing", type: :system, js: true do
  let(:user) { FactoryBot.create(:user, :confirmed) }
  let(:collected_show) { FactoryBot.create(:show, :with_premiere_date) }
  let(:season) { collected_show.seasons_without_specials.first }
  let(:episode) { season.episodes.first }
  let(:movie) { FactoryBot.create(:movie, translated_title: "A collected movie") }
  let(:bluray) { FactoryBot.create(:collection_format, :common) }

  before do
    entry = FactoryBot.create(:collection_item, user:, item: episode)
    FactoryBot.create(:collection_item_format, collection_item: entry, collection_format: bluray)
    FactoryBot.create(:collection_item, user:, item: movie)
  end

  it "filters and sorts through Turbo while retaining the surrounding page" do
    visit user_path(user)
    click_link "Collection", exact: true
    expect(page).to have_css("#collection_groups h6", text: movie.translated_title)
    page.execute_script("document.body.dataset.collectionTest = 'retained'")

    expect(page).to have_css(".ss-main.collection-formats > .ss-arrow")
    slim_select "Blu-ray", from: "collection-formats"
    expect(page).not_to have_css("#collection_groups h6", text: movie.translated_title)
    expect(page).to have_css("#collection_groups h6", text: collected_show.translated_title)
    expect(page).to have_content("1 matching episode")
    expect(page.evaluate_script("document.body.dataset.collectionTest")).to eq("retained")

    find(".ss-main.collection-formats .ss-value-delete").click
    expect(page).to have_css("#collection_groups h6", text: movie.translated_title)
    slim_select "Title A–Z", from: "collection-sort"
    expect(page).to have_current_path(/sort=title/)
    expect(page).to have_css("#collection_groups > div:first-child h6", text: movie.translated_title)

    find("label", text: "Movies", exact_text: true).click
    expect(page).not_to have_css("#collection_groups h6", text: movie.translated_title)
    expect(page).to have_current_path(/hidden_media_types.*Movie/)
    expect(page).not_to have_css("#collection_content[busy]")
    page.go_back
    expect(page).to have_css("#collection_groups h6", text: movie.translated_title)
  end

  it "opens grouped shows and displays Specials separately" do
    special = FactoryBot.create(:episode, season: collected_show.seasons.find_by!(number: 0), translated_name: "Special episode")
    FactoryBot.create(:collection_item, user:, item: special)

    visit user_collection_path(user)
    find("#collection_show_#{collected_show.id} h6").click
    expect(page).to have_css("#collection_content summary", text: "Specials")
    expect(page).to have_link("E1 · #{episode.translated_name}")
    scroll_to find("#collection_season_#{special.season_id}"), align: :center
    expect(page).to have_link("E1 · Special episode")
    click_link "Back to collection"
    expect(page).to have_css("#collection_groups h6", text: collected_show.translated_title)
  end

  it "lets the owner remove movies and filtered show ownership from the collection" do
    second = FactoryBot.create(:episode, season:, number: 2)
    FactoryBot.create(:collection_item, user:, item: second)
    sign_in user
    visit user_collection_path(user)

    find('button[aria-label="More options for A collected movie"]').click
    within(".collection_movie_#{movie.id}_options") { click_button "Delete" }
    within("dialog[open]") { click_button "Yes" }
    expect(page).not_to have_css("#collection_movie_#{movie.id}")

    expect(page).to have_css(".ss-main.collection-formats > .ss-arrow")
    slim_select "Blu-ray", from: "collection-formats"
    expect(page).to have_content("1 matching episode")
    find("#collection_show_#{collected_show.id} h6").click
    find("button[aria-label='More options for #{collected_show.translated_title}']").click
    within(".collection_show_#{collected_show.id}_options") { click_button "Delete" }
    within("dialog[open]") do
      expect(page).to have_content("2 owned episodes will be removed")
      expect(page).to have_content("hidden by your format filters")
      click_button "Yes"
    end
    expect(page).not_to have_css("#collection_card_season_#{season.id}")
    expect(page).to have_current_path(/collection\/shows\//)
    expect(user.collection_items).to be_empty

    page.refresh
    expect(page).to have_content("No collection items match these filters.")
  end
end
