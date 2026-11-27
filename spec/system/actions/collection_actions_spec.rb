require "rails_helper"

RSpec.describe "Collection actions", type: :system, js: true do
  let(:user) { FactoryBot.create(:user, :confirmed) }
  let(:movie) { FactoryBot.create(:movie, :with_release_date) }
  let(:show) { FactoryBot.create(:show, :with_premiere_date) }
  let(:season) { show.seasons_without_specials.first }
  let(:episode) { season.episodes.first }
  let(:dialog_selector) { 'dialog[data-controller="collection-dialog"]' }

  before do
    CollectionFormat::COMMON_NAMES.each { |name| FactoryBot.create(:collection_format, :common, name:) }
    sign_in user
  end

  def open_collection(record, compact: false)
    click_button "#{record.class.polymorphic_name}_#{record.id}_more_options" if compact
    find("button[data-controller='collection-button'][data-record-type='#{record.class.polymorphic_name}'][data-record-id='#{record.id}']", match: :first).click
    expect(page).to have_css("#{dialog_selector}[open]")
    expect(page).not_to have_content("Loading collection…")
  end

  def expect_closed
    expect(page).not_to have_css("#{dialog_selector}[open]")
  end

  it "adds and manages ownership and formats from a movie page" do
    visit movie_path(movie)
    open_collection(movie)
    click_button "Add to collection"
    expect_closed
    expect(user.collection_items.count).to eq(1)

    open_collection(movie)
    click_button "Add formats…"
    check "Blu-ray", allow_label_click: true
    fill_in "Custom format", with: "Digital — Apple TV"
    click_button "Add choice"
    expect(user.collection_formats.count).to eq(0)
    click_button "Add formats", exact: true
    expect_closed
    expect(user.collection_items.count).to eq(1)
    expect(user.collection_formats.pluck(:name)).to eq(["Digital — Apple TV"])

    open_collection(movie)
    click_button "Remove formats…"
    check "Digital — Apple TV", allow_label_click: true
    click_button "Remove formats", exact: true
    expect_closed
    expect(user.collection_items.count).to eq(1)
    expect(user.collection_formats.count).to eq(0)

    open_collection(movie)
    click_button "Remove from collection", exact: true
    click_button "Remove from collection", exact: true
    expect_closed
    expect(user.collection_items.count).to eq(0)
    expect(page).to have_css("button[data-controller='collection-button'][data-status='none']")
  end

  it "cancels custom formats without saving them" do
    visit movie_path(movie)
    open_collection(movie)
    fill_in "Custom format", with: "VHS"
    click_button "Add choice"
    click_button "Cancel"
    expect_closed
    expect(user.collection_items.count).to eq(0)
    expect(user.collection_formats.count).to eq(0)
    open_collection(movie)
    expect(page).not_to have_field("VHS", type: "checkbox")
    find(dialog_selector).send_keys(:escape)
    expect_closed
  end

  it "adds a released episode from its detail page" do
    visit show_season_episode_path(episode, season_id: season, show_id: show)
    open_collection(episode)
    check "Digital", allow_label_click: true
    click_button "Add to collection"
    expect_closed
    expect(user.collection_items.pluck(:item_type, :item_id)).to eq([["Episode", episode.id]])
    expect(page).to have_css("button[data-controller='collection-button'][data-status='completed']")
  end

  it "adds a show's released regular episodes from the show page" do
    special = FactoryBot.create(:episode, season: show.seasons.find_by!(number: 0))
    future = FactoryBot.create(:episode, season:, number: 2, original_air_date: Date.tomorrow)
    visit show_path(show)
    open_collection(show)
    check "Blu-ray", allow_label_click: true
    click_button "Add to collection"
    expect_closed
    expect(user.collection_items.pluck(:item_id)).to eq([episode.id])
    expect(user.collection_items.exists?(item: [special, future])).to be(false)
  end

  it "adds a season from the compact actions on its show page" do
    visit show_path(show)
    open_collection(season, compact: true)
    click_button "Add to collection"
    expect_closed
    expect(user.collection_items.pluck(:item_id)).to eq([episode.id])
    expect(page).to have_css("button[data-controller='collection-button'][data-record-type='Show'][data-status='completed']")
  end

  it "adds an episode from the compact actions on its season page" do
    visit show_season_path(season, show_id: show)
    open_collection(episode, compact: true)
    click_button "Add to collection"
    expect_closed
    expect(user.collection_items.pluck(:item_id)).to eq([episode.id])
    expect(page).to have_css("button[data-controller='collection-button'][data-record-type='Season'][data-status='completed']")
  end

  it "applies formats to owned episodes by default and adds missing episodes only with explicit scope" do
    second = FactoryBot.create(:episode, season:, number: 2)
    original = Manage::Collection.new(user).add!(episode, formats: ["VHS"]).first
    visit show_season_path(season, show_id: show)
    open_collection(season)
    click_button "Add episodes or formats…"
    expect(page).to have_checked_field("Owned episodes only (1)")
    check "Blu-ray", allow_label_click: true
    click_button "Add formats", exact: true
    expect_closed
    expect(user.collection_items.count).to eq(1)
    open_collection(season)
    click_button "Add episodes or formats…"
    choose "All released episodes (2)"
    check "Digital", allow_label_click: true
    click_button "Add to collection"
    expect_closed
    expect(user.collection_items.pluck(:item_id)).to match_array([episode.id, second.id])
    expect(CollectionItem.includes(:formats).find(original.id).formats.map(&:name)).to match_array(["Blu-ray", "Digital", "VHS"])

    blu_ray = CollectionFormat.common.find_by!(name: "Blu-ray")
    visit user_collection_show_path(user, show, formats: [blu_ray.id])
    scroll_to find("#collection_season_#{season.id}"), align: :center
    expect(page).to have_content("1 matching episode")
    expect(page).to have_link("E1 · #{episode.translated_name}")
    expect(page).to have_no_link("E2 · #{second.translated_name}")
  end

  it "adds movies, shows, seasons and episodes from a user's stack" do
    stack = FactoryBot.create(:stack, user:)
    [movie, episode, season, show].each { |record| stack.add!(record) }
    visit user_stack_path(stack, user_id: user)
    [movie, episode, season, show].each do |record|
      open_collection(record, compact: true)
      if page.has_button?("Add episodes or formats…", wait: 0)
        click_button "Add episodes or formats…"
        check "Digital", allow_label_click: true
        click_button "Add formats", exact: true
      else
        click_button "Add to collection"
      end
      expect_closed
    end
    expect(user.collection_items.count).to eq(2)
    expect(stack.stack_items.count).to eq(4)
  end

  it "adds a movie from an official stack" do
    stack = FactoryBot.create(:stack, user: nil)
    stack.add!(movie)
    visit official_stack_path(stack)
    open_collection(movie, compact: true)
    click_button "Add to collection"
    expect_closed
    expect(user.collection_items.exists?(item: movie)).to be(true)
  end

  it "adds from the watchlist without removing the watchlist entry" do
    user.watchlist!.add!(movie)
    visit watchlist_user_path(user)
    open_collection(movie, compact: true)
    click_button "Add to collection"
    expect_closed
    expect(user.collection_items.exists?(item: movie)).to be(true)
    expect(user.watchlisted?(movie)).to be(true)
  end

  it "adds a movie and show from their compact actions on a franchise page" do
    franchise = FactoryBot.create(:franchise)
    [movie, show].each { |record| FactoryBot.create(:franchise_item, franchise:, record:) }
    visit franchise_path(franchise)
    [movie, show].each do |record|
      open_collection(record, compact: true)
      click_button "Add to collection"
      expect_closed
    end
    expect(user.collection_items.count).to eq(2)
  end

  it "disables collection actions for an unreleased title" do
    movie.update_columns(release_date: Date.tomorrow)
    visit movie_path(movie)
    expect(page).to have_css("button[data-controller='collection-button'][disabled]")
  end
end
