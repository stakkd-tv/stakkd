# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Company filters", type: :system, js: true do
  scenario "Filtering companies" do
    uk = FactoryBot.create(:country, translated_name: "Great Britain")
    us = FactoryBot.create(:country, translated_name: "United States")
    FactoryBot.create(
      :company,
      name: "Evil Corp",
      country: us
    )
    FactoryBot.create(
      :company,
      name: "Other Corp",
      country: uk
    )

    visit companies_path

    # Filtering country
    select "Great Britain", from: "country_id"
    click_button "Apply filter"
    expect(page).to have_content("Other Corp")
    expect(page).not_to have_content("Evil Corp")
    select "None selected", from: "country_id"
    click_button "Apply filter"
    expect(page).to have_content("Evil Corp")
    expect(page).to have_content("Other Corp")
  end

  scenario "Filtering companies with load more" do
    uk = FactoryBot.create(:country, translated_name: "Great Britain")
    us = FactoryBot.create(:country, translated_name: "United States")
    36.times do
      FactoryBot.create(
        :company,
        name: "Evil Corp",
        country: us
      )
    end
    FactoryBot.create(
      :company,
      # Purposefully use a name that will appear at the end of results ordered by name, this is so that
      # we can test that it never appears regardless of what page we're on and to ensure that this record
      # will not appear on page 1 (would not appear before we scroll).
      name: "Zombie Zombie Zombie",
      country: uk
    )

    visit companies_path

    select "United States", from: "country_id"
    click_button "Apply filter"

    # It applies filter when loading more (Never displays Zombie Zombie Zombie)
    expect(page).to have_css("h3", text: "Evil Corp", count: 12)
    expect(page).not_to have_content("Zombie Zombie Zombie")
    page.execute_script("window.scrollTo(0, document.body.scrollHeight)")
    sleep 1 # This is dirty. We need this here so that we don't trigger any false positives
    expect(page).to have_css("h3", text: "Evil Corp", count: 24)
    expect(page).not_to have_content("Zombie Zombie Zombie")
    page.execute_script("window.scrollTo(0, document.body.scrollHeight)")
    sleep 1
    expect(page).to have_css("h3", text: "Evil Corp", count: 36)
    expect(page).not_to have_content("Zombie Zombie Zombie")
    page.execute_script("window.scrollTo(0, document.body.scrollHeight)")
    sleep 1
    expect(page).to have_css("h3", text: "Evil Corp", count: 36)
    expect(page).not_to have_content("Zombie Zombie Zombie") # The result NEVER appears
  end
end
