# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Movie form", type: :system, js: true do
  before do
    FactoryBot.create(:language)
    @uk = FactoryBot.create(:country, code: "GB", translated_name: "United Kingdom")
    @saudi = FactoryBot.create(:country, code: "KS", translated_name: "Saudi Arabia")

    @action = FactoryBot.create(:genre, name: "Action")
    @suspense = FactoryBot.create(:genre, name: "Suspense")

    @company1 = FactoryBot.create(:company, country: @uk, name: "Company 1", logos: [Rack::Test::UploadedFile.new("spec/support/assets/399x399.png", "image/png")])
    @company2 = FactoryBot.create(:company, country: @uk, name: "Company 2", logos: [Rack::Test::UploadedFile.new("spec/support/assets/400x400.png", "image/png")])

    @certification = FactoryBot.create(:certification, country: @uk, code: "PG", description: "Parental Guidance")
    FactoryBot.create(:certification, country: @saudi, code: "ABC")

    user = FactoryBot.create(:user)
    sign_in(user)
  end

  scenario "Using the movie form", :ignore_form_failures do
    visit movies_path
    expect(page).to have_content("Movies")

    # Details, TODO: Failures. Not urgent as failures are tested in request specs
    click_link "Add a movie"
    fill_in "movie_translated_title", with: "Test title"
    fill_in "movie_original_title", with: "Original title"
    click_button "Save"
    expect(page).to have_content("Movie was successfully created.")
    movie = Movie.last

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

    # Backgrounds
    click_link "Backgrounds"
    expect(page).to have_css("a[data-active='true']", text: "Backgrounds")
    expect(page).to have_content("Width must be between 1280px and 3840px")
    attach_file "upload_input", [Rails.root.join("spec/support/assets/1279x719.png"), Rails.root.join("spec/support/assets/1280x720.png")]
    using_wait_time 5 do
      expect(page).to have_content("1280x720.png uploaded")
      expect(page).to have_content("1279x719.png: Width must be between 1280px and 3840px, Height must be between 720px and 2160px")
    end
    expect(page).to have_css("img[src*='1280x720.png']")
    expect(page).not_to have_css("img[src*='1279x719.png']")

    # Logos
    click_link "Logos"
    expect(page).to have_css("a[data-active='true']", text: "Logos")
    expect(page).to have_content("Width must be between 400px and 3000px")
    attach_file "upload_input", [Rails.root.join("spec/support/assets/400x400.png"), Rails.root.join("spec/support/assets/399x399.png")]
    using_wait_time 5 do
      expect(page).to have_content("400x400.png uploaded")
      expect(page).to have_content("399x399.png: Width must be between 400px and 3000px, Height must be between 400px and 3000px")
    end
    expect(page).to have_css("img[src*='400x400.png']")
    expect(page).not_to have_css("img[src*='399x399.png']")

    # Alternative Names
    click_link "Alternative Names"
    expect(page).to have_css("a[data-active='true']", text: "Alternative Names")
    expect(page).to have_content("Add a new alternative name")
    fill_in "alternative_name_name", with: "New alt name"
    fill_in "alternative_name_type", with: "New alt type"
    select "Saudi Arabia", from: "alternative_name_country_id"
    click_button "Save"
    using_wait_time 5 do
      expect(page).to have_css "div.tabulator-cell", text: "New alt name"
      expect(page).to have_css "div.tabulator-cell", text: "New alt type"
      expect(page).to have_css "div.tabulator-cell", text: "Saudi Arabia"
    end
    alternative_name = AlternativeName.first
    expect(alternative_name.name).to eq "New alt name"
    expect(alternative_name.type).to eq "New alt type"
    expect(alternative_name.country).to eq @saudi
    name_cell = find("div.tabulator-cell", text: "New alt name")
    name_cell.click
    find("input:focus").send_keys([:control, "a"], :backspace)
    find("input:focus").send_keys("Updated alt name")
    type_cell = find("div.tabulator-cell", text: "New alt type")
    type_cell.click
    find("input:focus").send_keys([:control, "a"], :backspace)
    find("input:focus").send_keys("Updated alt type")
    country_cell = find("div.tabulator-cell", text: "Saudi Arabia")
    country_cell.click
    find("input:focus").send_keys([:control, "a"], :backspace)
    find("input:focus").send_keys("United Kingdom")
    expect(page).to have_css("div.dropdown-option", text: "United Kingdom")
    expect(page).not_to have_css("div.dropdown-option", text: "Saudi Arabia")
    find("div.dropdown-option", text: "United Kingdom").click
    using_wait_time 5 do
      expect(page).to have_css "div.tabulator-cell", text: "Updated alt name"
      expect(page).to have_css "div.tabulator-cell", text: "Updated alt type"
      expect(page).to have_css "div.tabulator-cell", text: "United Kingdom"
    end
    alternative_name.reload
    expect(alternative_name.name).to eq "Updated alt name"
    expect(alternative_name.type).to eq "Updated alt type"
    expect(alternative_name.country).to eq @uk

    # Genres
    click_link "Genres"
    expect(page).to have_css("a[data-active='true']", text: "Genres")
    find("div.ss-main").click
    expect(page).to have_css("div.ss-option", text: "Action")
    expect(page).to have_css("div.ss-option", text: "Suspense")
    find("div.ss-search>input").send_keys("Sus")
    expect(page).not_to have_css("div.ss-option", text: "Action")
    expect(page).to have_css("div.ss-option", text: "Suspense")
    find("div.ss-option", text: "Suspense").click
    expect(page).to have_css("div.ss-single", text: "Suspense")
    find("button[role='submit']").click
    using_wait_time 5 do
      expect(page).to have_css "div.tabulator-cell", text: "Suspense"
      expect(movie.reload.genres).to eq [@suspense]
    end
    find("div.tabulator-cell>svg").click
    using_wait_time 5 do
      expect(page).not_to have_css "div.tabulator-cell", text: "Suspense"
      expect(movie.reload.genres).to eq []
    end

    # Companies
    click_link "Companies"
    expect(page).to have_css("a[data-active='true']", text: "Companies")
    find("div.ss-main").click
    expect(page).to have_css("div.ss-option", text: "Company 1")
    expect(page).to have_css("div.ss-option", text: "Company 2")
    find("div.ss-search>input").send_keys("ny 2")
    expect(page).not_to have_css("div.ss-option", text: "Company 1")
    expect(page).to have_css("div.ss-option", text: "Company 2")
    find("div.ss-option", text: "Company 2").click
    expect(page).to have_css("div.ss-single", text: "Company 2")
    find("button[role='submit']").click
    using_wait_time 5 do
      expect(page).to have_css "div.tabulator-cell", text: "Company 2"
      expect(page).to have_css "img[src*='400x400']"
      expect(movie.reload.companies).to eq [@company2]
    end
    find("div.tabulator-cell>svg").click
    using_wait_time 5 do
      expect(page).not_to have_css "div.tabulator-cell", text: "Company 2"
      expect(page).not_to have_css "img[src*='400x400']"
      expect(movie.reload.companies).to eq []
    end

    # Keywords
    click_link "Keywords"
    expect(page).to have_css("a[data-active='true']", text: "Keywords")
    find("div.ss-main").click
    find("div.ss-search>input").send_keys("Hello there")
    expect(page).to have_content("Press \"Enter\" to add Hello there")
    find("div.ss-addable").click
    expect(page).to have_css("div.ss-single", text: "Hello there")
    find("button[role='submit']").click
    using_wait_time 5 do
      expect(page).to have_css "div.tabulator-cell", text: "Hello there"
      expect(movie.reload.keyword_list).to eq ["Hello there"]
    end
    find("div.tabulator-cell>svg").click
    using_wait_time 5 do
      expect(page).not_to have_css "div.tabulator-cell", text: "Hello there"
      expect(movie.reload.keyword_list).to eq []
    end

    # Releases
    click_link "Releases"
    expect(page).to have_css("a[data-active='true']", text: "Releases")
    fill_in "release_date", with: Date.new(2025, 2, 1)
    select "Theatrical", from: "release_type"
    find("div.ss-main").click
    find("div.ss-option", text: "GB - PG").click
    fill_in "release_note", with: "Test release note"
    click_button "Save"
    using_wait_time 5 do
      expect(page).to have_css "div.tabulator-cell", text: "01-02-2025"
      expect(page).to have_css "div.tabulator-cell", text: "Theatrical"
      expect(page).to have_css "div.tabulator-cell", text: "PG"
      expect(page).to have_css "div.tabulator-cell", text: "Test release note"
      expect(movie.reload.releases.count).to eq 1
    end
    date_cell = find("div.tabulator-cell", text: "01-02-2025")
    date_cell.click
    expect(page).to have_css(".flatpickr-calendar")
    expect(page).to have_css(".flatpickr-day.selected", text: "1")
    selected_month = find("select.flatpickr-monthDropdown-months").value
    expect(selected_month).to eq("1") # 0 based index, so February
    selected_year = find("input.numInput.cur-year").value
    expect(selected_year).to eq("2025")
    certification_cell = find("div.tabulator-cell", text: "PG")
    certification_cell.click
    expect(page).to have_css(".dropdown-option", text: "PG")
    expect(page).not_to have_css(".dropdown-option", text: "ABC") # Does not show other country certification
    find("div.tabulator-cell>svg").click
    using_wait_time 5 do
      expect(page).not_to have_css "div.tabulator-cell", text: "01-02-2025"
      expect(movie.reload.releases).to eq []
    end

    # Taglines
    click_link "Taglines"
    expect(page).to have_css("a[data-active='true']", text: "Taglines")
    fill_in "tagline_tagline", with: "Test tagline"
    click_button "Save"
    using_wait_time 5 do
      expect(page).to have_css "div.tabulator-cell", text: "Test tagline"
    end
    tagline = Tagline.first
    expect(tagline.tagline).to eq "Test tagline"
    expect(tagline.position).to eq 1
    tagline_cell = find("div.tabulator-cell", text: "Test tagline")
    tagline_cell.click
    find("input:focus").send_keys([:control, "a"], :backspace)
    find("input:focus").send_keys("Updated tagline", :enter)
    using_wait_time 5 do
      expect(page).to have_css "div.tabulator-cell", text: "Updated tagline"
    end
    tagline.reload
    expect(tagline.tagline).to eq "Updated tagline"
    fill_in "tagline_tagline", with: "Another tagline"
    click_button "Save"
    using_wait_time 5 do
      expect(page).to have_css "div.tabulator-cell", text: "Another tagline"
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
      expect(movie.videos.count).to eq 1
    end
    video = Video.first
    expect(video.source).to eq "YouTube"
    expect(video.source_key).to eq "abc123"
    expect(video.type).to eq "Trailer"
    expect(video.name).to eq "YouTube Trailer"
    expect(video.thumbnail_url).to eq "https://example.com/thumbnail.jpg"
    find("div.tabulator-cell>svg").click
    using_wait_time 5 do
      expect(page).not_to have_css "div.tabulator-cell", text: "abc123"
      expect(page).not_to have_css "div.tabulator-cell", text: "YouTube Trailer"
      expect(movie.videos).to eq []
    end
  end
end
