# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Show filters", type: :system, js: true do
  scenario "Filtering movies" do
    action = FactoryBot.create(:genre, name: "Action")
    comedy = FactoryBot.create(:genre, name: "Comedy")
    show1 = FactoryBot.create(
      :show,
      translated_title: "Game of Thrones",
      genres: [action],
      country: FactoryBot.build(:country, code: "UK", translated_name: "Great Britain"),
      keyword_list: ["rubbish tv show"]
    )
    season1 = FactoryBot.create(:season, show: show1)
    FactoryBot.create(:episode, number: 1, season: season1, original_air_date: Date.new(2011, 4, 17))
    FactoryBot.create(:episode, number: 2, season: season1, original_air_date: Date.new(2013, 5, 1))
    FactoryBot.create(:content_rating, show: show1, certification: FactoryBot.build(:certification, media_type: "Show", code: "PG", country: show1.country))
    show2 = FactoryBot.create(
      :show,
      translated_title: "Avatar: The Last Airbender",
      genres: [comedy],
      country: FactoryBot.build(:country, code: "US", translated_name: "United States"),
      keyword_list: ["greatest tv show of all time"]
    )
    season2 = FactoryBot.create(:season, show: show2)
    FactoryBot.create(:episode, number: 1, season: season2, original_air_date: Date.new(2005, 2, 21))
    FactoryBot.create(:episode, number: 2, season: season2, original_air_date: Date.new(2006, 5, 1))
    FactoryBot.create(:content_rating, show: show2, certification: FactoryBot.build(:certification, media_type: "Show", code: "NR", country: show2.country))

    visit shows_path

    # Filtering premiere dates
    fill_in "premiere_date_from", with: Date.new(2005, 1, 1)
    fill_in "premiere_date_to", with: Date.new(2005, 12, 30)
    click_button "Apply filter"
    expect(page).to have_content("Avatar: The Last Airbender")
    expect(page).not_to have_content("Game of Thrones")
    fill_in "premiere_date_from", with: Date.new(2011, 1, 1)
    fill_in "premiere_date_to", with: Date.new(2011, 12, 30)
    click_button "Apply filter"
    expect(page).to have_content("Game of Thrones")
    expect(page).not_to have_content("Avatar: The Last Airbender")
    fill_in "premiere_date_from", with: Date.new(2005, 1, 1)
    fill_in "premiere_date_to", with: Date.new(2012, 1, 1)
    click_button "Apply filter"
    expect(page).to have_content("Avatar: The Last Airbender")
    expect(page).to have_content("Game of Thrones")
    fill_in "premiere_date_from", with: ""
    fill_in "premiere_date_to", with: ""
    click_button "Apply filter"

    # Filtering episode air dates
    fill_in "episode_air_date_from", with: Date.new(2006, 5, 1)
    fill_in "episode_air_date_to", with: Date.new(2006, 5, 1)
    click_button "Apply filter"
    expect(page).to have_content("Avatar: The Last Airbender")
    expect(page).not_to have_content("Game of Thrones")
    fill_in "episode_air_date_from", with: Date.new(2013, 5, 1)
    fill_in "episode_air_date_to", with: Date.new(2013, 5, 1)
    click_button "Apply filter"
    expect(page).to have_content("Game of Thrones")
    expect(page).not_to have_content("Avatar: The Last Airbender")
    fill_in "episode_air_date_from", with: Date.new(2006, 1, 1)
    fill_in "episode_air_date_to", with: Date.new(2013, 1, 1)
    click_button "Apply filter"
    expect(page).to have_content("Avatar: The Last Airbender")
    expect(page).to have_content("Game of Thrones")
    fill_in "episode_air_date_from", with: ""
    fill_in "episode_air_date_to", with: ""
    click_button "Apply filter"

    # Filtering genres
    # The checkboxes are not visible and can only be clicked from label
    find("label", text: "Action").click # Check "Action"
    click_button "Apply filter"
    expect(page).to have_content("Game of Thrones")
    expect(page).not_to have_content("Avatar: The Last Airbender")
    find("label", text: "Action").click # Uncheck
    click_button "Apply filter"
    expect(page).to have_content("Game of Thrones")
    expect(page).to have_content("Avatar: The Last Airbender")

    # Filtering country
    select "Great Britain", from: "country_id"
    click_button "Apply filter"
    expect(page).to have_content("Game of Thrones")
    expect(page).not_to have_content("Avatar: The Last Airbender")
    select "None selected", from: "country_id"
    click_button "Apply filter"
    expect(page).to have_content("Avatar: The Last Airbender")
    expect(page).to have_content("Game of Thrones")

    # Content ratings
    find_all("div.ss-main").first.click
    expect(page).to have_css("div.ss-option", text: "UK - PG")
    expect(page).to have_css("div.ss-option", text: "US - NR")
    find_all("div.ss-search>input").first.send_keys("PG")
    expect(page).to have_css("div.ss-option", text: "UK - PG")
    expect(page).not_to have_css("div.ss-option", text: "US - NR")
    find("div.ss-option", text: "UK - PG").click
    expect(page).to have_css("div.ss-value-text", text: "UK - PG")
    click_button "Apply filter"
    expect(page).to have_content("Game of Thrones")
    expect(page).not_to have_content("Avatar: The Last Airbender")
    find_all("div.ss-value-delete").first.click
    expect(page).not_to have_css("div.ss-value-text", text: "UK - PG")

    # Keywords
    find_all("div.ss-main").last.click
    expect(page).to have_css("div.ss-option", text: "rubbish tv show")
    expect(page).to have_css("div.ss-option", text: "greatest tv show of all time")
    find_all("div.ss-search>input").last.send_keys("Hello there")
    expect(page).to have_content("Press \"Enter\" to add Hello there")
    find_all("div.ss-addable").last.click
    expect(page).to have_css("div.ss-value-text", text: "Hello there")
    click_button "Apply filter"
    expect(page).not_to have_content("Avatar: The Last Airbender")
    expect(page).not_to have_content("Game of Thrones")
    find_all("div.ss-value-delete").last.click
    expect(page).not_to have_css("div.ss-value-text", text: "Hello there")
    find_all("div.ss-main").last.click
    find_all("div.ss-search>input").last.send_keys("rubbish tv show")
    expect(page).to have_css("div.ss-option", text: "rubbish tv show")
    find("div.ss-option", text: "rubbish tv show").click
    click_button "Apply filter"
    expect(page).to have_content("Game of Thrones")
    expect(page).not_to have_content("Avatar: The Last Airbender")
  end

  scenario "Filtering shows with load more" do
    action = FactoryBot.create(:genre, name: "Action")
    comedy = FactoryBot.create(:genre, name: "Comedy")

    country = FactoryBot.create(:country, code: "UK", translated_name: "Great Britain")
    certification = FactoryBot.create(:certification, media_type: "Show", code: "PG", country:)
    36.times do
      show = FactoryBot.create(
        :show,
        translated_title: "Game of Thrones",
        genres: [action],
        country:,
        keyword_list: ["rubbish tv show"]
      )
      season = FactoryBot.create(:season, show:)
      FactoryBot.create(:episode, number: 1, season:, original_air_date: Date.new(2011, 4, 17))
      FactoryBot.create(:episode, number: 2, season:, original_air_date: Date.new(2013, 5, 1))
      FactoryBot.create(:content_rating, show:, certification:)
    end
    show2 = FactoryBot.create(
      :show,
      # Purposefully use a name that will appear at the end of results ordered by name, this is so that
      # we can test that it never appears regardless of what page we're on and to ensure that this record
      # will not appear on page 1 (would not appear before we scroll).
      translated_title: "Zombie Zombie Zombie",
      genres: [comedy],
      country: FactoryBot.build(:country, code: "US", translated_name: "United States"),
      keyword_list: ["greatest tv show of all time"]
    )
    season2 = FactoryBot.create(:season, show: show2)
    FactoryBot.create(:episode, number: 1, season: season2, original_air_date: Date.new(2005, 2, 21))
    FactoryBot.create(:episode, number: 2, season: season2, original_air_date: Date.new(2006, 5, 1))
    FactoryBot.create(:content_rating, show: show2, certification: FactoryBot.build(:certification, media_type: "Show", code: "NR", country: show2.country))

    visit shows_path

    fill_in "premiere_date_from", with: Date.new(2011, 1, 1)
    fill_in "premiere_date_to", with: Date.new(2011, 12, 30)
    fill_in "episode_air_date_from", with: Date.new(2013, 5, 1)
    fill_in "episode_air_date_to", with: Date.new(2013, 5, 1)
    find("label", text: "Action").click # Check "Action"
    select "Great Britain", from: "country_id"
    # Content ratings
    find_all("div.ss-main").first.click
    find_all("div.ss-search>input").first.send_keys("PG")
    expect(page).to have_css("div.ss-option", text: "UK - PG")
    expect(page).not_to have_css("div.ss-option", text: "US - NR")
    find("div.ss-option", text: "UK - PG").click
    expect(page).to have_css("div.ss-value-text", text: "UK - PG")
    # Keywords
    find_all("div.ss-main").last.click
    expect(page).to have_css("div.ss-option", text: "rubbish tv show")
    expect(page).to have_css("div.ss-option", text: "greatest tv show of all time")
    find_all("div.ss-search>input").last.send_keys("rubbish tv show")
    expect(page).to have_css("div.ss-option", text: "rubbish tv show")
    find("div.ss-option", text: "rubbish tv show").click
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
    expect(page).not_to have_content("Zombie Zombie Zombie") # Show never appears
  end
end
