# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Movie filters", type: :system, js: true do
  scenario "Filtering movies" do
    action = FactoryBot.create(:genre, name: "Action")
    comedy = FactoryBot.create(:genre, name: "Comedy")
    FactoryBot.create(
      :movie,
      translated_title: "Ready Player One",
      genres: [action],
      releases: [FactoryBot.build(:release, type: Release::DIGITAL, date: "2025-01-01")],
      country: FactoryBot.build(:country, code: "UK", translated_name: "Great Britain")
    )
    FactoryBot.create(
      :movie,
      translated_title: "Jurassic Park",
      genres: [comedy],
      releases: [FactoryBot.build(:release, type: Release::THEATRICAL, date: "2025-01-01")],
      country: FactoryBot.build(:country, code: "US", translated_name: "United States")
    )

    visit movies_path

    # Filtering releases
    select "Digital", from: "release_type"
    fill_in "release_date_from", with: Date.new(2025, 1, 1)
    fill_in "release_date_to", with: Date.new(2025, 1, 1)
    click_button "Apply filter"
    expect(page).to have_content("Ready Player One")
    expect(page).not_to have_content("Jurassic Park")
    select "Theatrical", from: "release_type"
    fill_in "release_date_from", with: Date.new(2025, 1, 1)
    fill_in "release_date_to", with: Date.new(2025, 1, 1)
    click_button "Apply filter"
    expect(page).to have_content("Jurassic Park")
    expect(page).not_to have_content("Ready Player One")
    select "All Releases", from: "release_type"
    fill_in "release_date_from", with: Date.new(2025, 1, 1)
    fill_in "release_date_to", with: Date.new(2025, 1, 1)
    click_button "Apply filter"
    expect(page).to have_content("Jurassic Park")
    expect(page).to have_content("Ready Player One")
    fill_in "release_date_from", with: ""
    fill_in "release_date_to", with: ""
    click_button "Apply filter"

    # Filtering genres
    # The checkboxes are not visible and can only be clicked from label
    find("label", text: "Action").click # Check "Action"
    click_button "Apply filter"
    expect(page).to have_content("Ready Player One")
    expect(page).not_to have_content("Jurassic Park")
    find("label", text: "Action").click # Uncheck
    click_button "Apply filter"
    expect(page).to have_content("Jurassic Park")
    expect(page).to have_content("Ready Player One")

    # Filtering country
    select "Great Britain", from: "country_id"
    click_button "Apply filter"
    expect(page).to have_content("Ready Player One")
    expect(page).not_to have_content("Jurassic Park")
    select "None selected", from: "country_id"
    click_button "Apply filter"
    expect(page).to have_content("Jurassic Park")
    expect(page).to have_content("Ready Player One")
  end

  scenario "Filtering movies with load more" do
    action = FactoryBot.create(:genre, name: "Action")
    comedy = FactoryBot.create(:genre, name: "Comedy")
    FactoryBot.create_list(
      :movie,
      13,
      translated_title: "Jurassic Park",
      genres: [action]
    )
    FactoryBot.create(
      :movie,
      translated_title: "Jurassic Park",
      genres: [comedy]
    )

    visit movies_path

    # It applies filter when loading more (only shows 13 results instead of 14)
    find("label", text: "Action").click # Check "Action"
    click_button "Apply filter"
    expect(page).to have_content("Jurassic Park", count: 12)
    page.execute_script("window.scrollTo(0, document.body.scrollHeight)")
    sleep 1 # TODO: This is dirty. We need this here so that we don't trigger any false positives
    expect(page).to have_content("Jurassic Park", count: 13)
  end
end
