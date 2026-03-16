# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Person filters", type: :system, js: true do
  scenario "Filtering people" do
    FactoryBot.create(
      :person,
      translated_name: "Dude One",
      dob: Date.new(2025, 1, 1),
      gender: Person::MALE,
      known_for: Person::ART
    )
    FactoryBot.create(
      :person,
      translated_name: "Dude Two",
      dob: Date.new(2025, 1, 2),
      gender: Person::FEMALE,
      known_for: Person::WRITING
    )

    visit people_path

    # Filtering releases
    fill_in "birthday_from", with: Date.new(2025, 1, 1)
    fill_in "birthday_to", with: Date.new(2025, 1, 1)
    click_button "Apply filter"
    expect(page).to have_content("Dude One")
    expect(page).not_to have_content("Dude Two")
    fill_in "birthday_from", with: Date.new(2025, 1, 2)
    fill_in "birthday_to", with: Date.new(2025, 1, 2)
    click_button "Apply filter"
    expect(page).to have_content("Dude Two")
    expect(page).not_to have_content("Dude 1")
    fill_in "birthday_from", with: ""
    fill_in "birthday_to", with: ""
    click_button "Apply filter"
    expect(page).to have_content("Dude One")
    expect(page).to have_content("Dude Two")

    # Filtering gender
    select "Male", from: "gender"
    click_button "Apply filter"
    expect(page).to have_content("Dude One")
    expect(page).not_to have_content("Dude Two")
    select "Female", from: "gender"
    click_button "Apply filter"
    expect(page).to have_content("Dude Two")
    expect(page).not_to have_content("Dude One")
    select "None selected", from: "gender"
    click_button "Apply filter"
    expect(page).to have_content("Dude One")
    expect(page).to have_content("Dude Two")

    # Filtering known for
    select "Art", from: "known_for"
    click_button "Apply filter"
    expect(page).to have_content("Dude One")
    expect(page).not_to have_content("Dude Two")
    select "Writing", from: "known_for"
    click_button "Apply filter"
    expect(page).to have_content("Dude Two")
    expect(page).not_to have_content("Dude One")
    select "None selected", from: "known_for"
    click_button "Apply filter"
    expect(page).to have_content("Dude One")
    expect(page).to have_content("Dude Two")
  end

  scenario "Filtering people with load more" do
    36.times do
      FactoryBot.create(
        :person,
        translated_name: "Dude One",
        gender: Person::MALE
      )
    end
    FactoryBot.create(
      :person,
      # Purposefully use a name that will appear at the end of results ordered by name, this is so that
      # we can test that it never appears regardless of what page we're on and to ensure that this record
      # will not appear on page 1 (would not appear before we scroll).
      translated_name: "Zombie Zombie Zombie",
      gender: Person::FEMALE
    )

    visit people_path

    select "Male", from: "gender"
    click_button "Apply filter"

    # It applies filter when loading more (Never displays Zombie Zombie Zombie)
    expect(page).to have_css("h3", text: "Dude One", count: 12)
    expect(page).not_to have_content("Zombie Zombie Zombie")
    page.execute_script("window.scrollTo(0, document.body.scrollHeight)")
    sleep 1 # This is dirty. We need this here so that we don't trigger any false positives
    expect(page).to have_css("h3", text: "Dude One", count: 24)
    expect(page).not_to have_content("Zombie Zombie Zombie")
    page.execute_script("window.scrollTo(0, document.body.scrollHeight)")
    sleep 1
    expect(page).to have_css("h3", text: "Dude One", count: 36)
    expect(page).not_to have_content("Zombie Zombie Zombie")
    page.execute_script("window.scrollTo(0, document.body.scrollHeight)")
    sleep 1
    expect(page).to have_css("h3", text: "Dude One", count: 36)
    expect(page).not_to have_content("Zombie Zombie Zombie") # The result NEVER appears
  end
end
