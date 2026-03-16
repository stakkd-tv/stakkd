# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Show form", type: :system, js: true do
  before do
    @show = FactoryBot.create(:show)

    FactoryBot.create(:person, translated_name: "John Doe")
    FactoryBot.create(:person, translated_name: "Obi Wan")

    user = FactoryBot.create(:user)
    sign_in(user)
  end

  scenario "Using the season form", :ignore_form_failures do
    visit show_path(@show)
    expect(page).to have_content(@show.translated_title)

    # Errors
    click_link "Add Season"
    fill_in "season_translated_name", with: " "
    fill_in "season_original_name", with: " "
    fill_in "season_number", with: "1"
    click_button "Save"
    expect(page).to have_content("Translated name can't be blank")
    expect(page).to have_content("Original name can't be blank")

    # Details
    fill_in "season_translated_name", with: "Test name"
    fill_in "season_original_name", with: "Original name"
    fill_in "season_number", with: "1"
    click_button "Save"
    expect(page).to have_content("Season was successfully created.")
    season = Season.last

    # Posters
    click_link "Posters"
    expect(page).to have_css("a[data-active='true']", text: "Posters")
    expect(page).to have_content("Width must be between 300px and 2000px")
    attach_file "upload_input", [Rails.root.join("spec/support/assets/299x449.png"), Rails.root.join("spec/support/assets/300x450.png")]
    using_wait_time 5 do
      expect(page).to have_content("300x450.png uploaded")
      expect(page).to have_content("299x449.png: Width must be between 300px and 2000px, Height must be between 450px and 3000px")
    end
    expect(page).to have_css("img[src*='300x450.png']")
    expect(page).not_to have_css("img[src*='299x449.png']")
    expect(season.posters.count).to eq 1

    # Season Regulars
    click_link "Season Regulars"
    expect(page).to have_css("a[data-active='true']", text: "Season Regulars")
    expect(page).to have_content("Add a season regular")
    fill_in "person", with: "obi wan"
    expect(page).to have_css("div.p-2", text: "Obi Wan")
    expect(page).not_to have_css("div.p-2", text: "John Doe") # Applies searching
    find("div.p-2", text: "Obi Wan").click
    fill_in "cast_member_character", with: "Test character"
    click_button "Save"
    using_wait_time 5 do
      expect(page).to have_css "div.tabulator-cell", text: "Obi Wan"
      expect(page).to have_css "div.tabulator-cell", text: "Test character"
      expect(season.reload.season_regulars.count).to eq 1
    end
    character_cell = find("div.tabulator-cell", text: "Test character")
    character_cell.click
    find("input:focus").send_keys([:control, "a"], :backspace)
    find("input:focus").send_keys("New character", :enter)
    using_wait_time 5 do
      expect(page).to have_css "div.tabulator-cell", text: "Obi Wan"
      expect(page).to have_css "div.tabulator-cell", text: "New character"
    end
    find("div.tabulator-cell>svg").click
    using_wait_time 5 do
      expect(page).not_to have_css "div.tabulator-cell", text: "Obi Wan"
      expect(page).not_to have_css "div.tabulator-cell", text: "New character"
      expect(season.reload.season_regulars).to eq []
    end
    # Add to all seasons
    fill_in "person", with: "obi wan"
    expect(page).to have_css("div.p-2", text: "Obi Wan")
    expect(page).not_to have_css("div.p-2", text: "John Doe") # Applies searching
    find("div.p-2", text: "Obi Wan").click
    fill_in "cast_member_character", with: "Test character"
    check "add_to_all_seasons"
    click_button "Save"
    using_wait_time 5 do
      expect(page).to have_css "p.text-center", text: "Obi Wan"
      expect(page).to have_css "small.text-center", text: "Test character"
      expect(@show.reload.season_regulars.count).to eq 1
      expect(season.reload.season_regulars.count).to eq 0
    end

    # Videos
    click_link "Videos"
    expect(page).to have_css("a[data-active='true']", text: "Videos")
    select "YouTube", from: "video_source"
    fill_in "video_source_key", with: "abc123"
    select "Trailer", from: "video_type"
    allow_any_instance_of(Videos::YouTube).to receive(:title).and_return("YouTube Trailer")
    allow_any_instance_of(Videos::YouTube).to receive(:thumbnail_url).and_return("https://example.com/thumbnail.jpg")
    click_button "Save"
    using_wait_time 5 do
      expect(page).to have_css "div.tabulator-cell", text: "abc123"
      expect(page).to have_css "div.tabulator-cell", text: "YouTube Trailer"
      expect(season.videos.count).to eq 1
    end
    video = Video.first
    expect(video.source).to eq "YouTube"
    expect(video.source_key).to eq "abc123"
    expect(video.type).to eq "Trailer"
    expect(video.name).to eq "YouTube Trailer"
    expect(video.thumbnail_url).to eq "https://example.com/thumbnail.jpg"
    expect(video.record).to eq season
    find("div.tabulator-cell>svg").click
    using_wait_time 5 do
      expect(page).not_to have_css "div.tabulator-cell", text: "abc123"
      expect(page).not_to have_css "div.tabulator-cell", text: "YouTube Trailer"
      expect(season.videos).to eq []
    end
  end
end
