# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Franchise filters", type: :system, js: true do
  scenario "Filtering franchises" do
    show1 = FactoryBot.create(:show, :with_premiere_date, date_for_premiere: Date.new(2011, 4, 17))
    franchise1 = FactoryBot.create(:franchise, translated_title: "Game of Thrones")
    FactoryBot.create(:franchise_item, franchise: franchise1, record: show1)
    show2 = FactoryBot.create(:show, :with_premiere_date, date_for_premiere: Date.new(2005, 2, 21))
    franchise2 = FactoryBot.create(:franchise, translated_title: "Avatar: The Last Airbender")
    FactoryBot.create(:franchise_item, franchise: franchise2, record: show2)

    visit franchises_path

    # Filtering release dates
    fill_in "release_dates_from", with: Date.new(2005, 2, 21)
    fill_in "release_dates_to", with: Date.new(2005, 2, 21)
    click_button "Apply filter"
    expect(page).to have_content("Avatar: The Last Airbender")
    expect(page).not_to have_content("Game of Thrones")
    fill_in "release_dates_from", with: Date.new(2011, 4, 17)
    fill_in "release_dates_to", with: Date.new(2011, 4, 17)
    click_button "Apply filter"
    expect(page).to have_content("Game of Thrones")
    expect(page).not_to have_content("Avatar: The Last Airbender")
    fill_in "release_dates_from", with: Date.new(2005, 1, 1)
    fill_in "release_dates_to", with: Date.new(2012, 1, 1)
    click_button "Apply filter"
    expect(page).to have_content("Avatar: The Last Airbender")
    expect(page).to have_content("Game of Thrones")
  end

  scenario "Filtering franchises with load more" do
    36.times do
      show = FactoryBot.create(:show, :with_premiere_date, date_for_premiere: Date.new(2011, 4, 17))
      franchise = FactoryBot.create(:franchise, translated_title: "Game of Thrones")
      FactoryBot.create(:franchise_item, franchise:, record: show)
    end
    show2 = FactoryBot.create(:show, :with_premiere_date, date_for_premiere: Date.new(2005, 2, 21))
    # Purposefully use a name that will appear at the end of results ordered by name, this is so that
    # we can test that it never appears regardless of what page we're on and to ensure that this record
    # will not appear on page 1 (would not appear before we scroll).
    franchise = FactoryBot.create(:franchise, translated_title: "Zombie Zombie Zombie")
    FactoryBot.create(:franchise_item, franchise:, record: show2)

    visit franchises_path

    fill_in "release_dates_from", with: Date.new(2011, 4, 17)
    fill_in "release_dates_to", with: Date.new(2011, 4, 17)
    click_button "Apply filter"

    expect(page).to have_css("h3", text: "Game of Thrones", count: 12)
    expect(page).not_to have_content("Zombie Zombie Zombie")
    page.execute_script("window.scrollTo(0, document.body.scrollHeight)")
    sleep 1 # This is dirty. We need this here so that we don't trigger any false positives
    expect(page).to have_css("h3", text: "Game of Thrones", count: 24)
    expect(page).not_to have_content("Zombie Zombie Zombie")
    page.execute_script("window.scrollTo(0, document.body.scrollHeight)")
    sleep 1
    expect(page).to have_css("h3", text: "Game of Thrones", count: 36)
    expect(page).not_to have_content("Zombie Zombie Zombie")
    page.execute_script("window.scrollTo(0, document.body.scrollHeight)")
    sleep 1
    expect(page).to have_css("h3", text: "Game of Thrones", count: 36)
    expect(page).not_to have_content("Zombie Zombie Zombie") # Franchise never appears
  end
end
