# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Rating actions", type: :system, js: true do
  let(:user) { FactoryBot.create(:user, :confirmed) }

  scenario "previewing, saving and removing a rating on a media detail page" do
    movie = FactoryBot.create(:movie, :with_release_date)
    sign_in user
    visit movie_path(movie)

    within("[data-rating-url-value='#{set_rating_movie_path(movie)}']") do
      find("button[aria-label='Rate 7 out of 10']").hover
      expect(page).to have_text("7 - Good")
      expect(page).to have_css("button[data-filled='true']", count: 7)
      expect(page).to have_css("button[data-score='7'] > span", count: 1, visible: true)
      expect(user.ratings.exists?(item: movie)).to be(false)
      expect(page).to have_no_text("Select your saved star again")
    end

    find("h3", text: movie.translated_title, match: :first).hover
    expect(page).to have_no_text("7 - Good")

    find("button[aria-label='Rate 7 out of 10']").click
    expect(page).to have_css("button[aria-label='Remove your 7/10 rating']")
    expect(user.ratings.find_by!(item: movie).score).to eq(7)
    expect(page).to have_text("Select your saved star again")

    find("button[aria-label='Remove your 7/10 rating']").click
    expect(page).to have_text("Unrated")
    expect(page).to have_no_text("Select your saved star again")
    expect(user.ratings.exists?(item: movie)).to be(false)
  end

  scenario "rating an episode from the image overlay at phone width" do
    episode = FactoryBot.create(:episode, translated_name: "A Quiet Crossing")
    season = episode.season
    show = season.show
    page.current_window.resize_to(390, 850)
    sign_in user
    visit show_season_path(season, show_id: show)

    within("#season_episodes") do
      star = find("button[aria-label='Rate A Quiet Crossing']")
      more_options = find("button[data-controller='more-options']")
      dimensions = more_options.native.rect
      expect(dimensions.width).to eq(dimensions.height)
      star.click
    end
    within("dialog[open]") do
      expect(page).to have_text(show.translated_title)
      expect(page).to have_text("A Quiet Crossing")
      star_positions = all("button[data-rating-target='star']").map { |button| button.native.rect.y }
      expect(star_positions.uniq.size).to eq(1)
      find("button[aria-label='Rate 9 out of 10']").click
      expect(page).to have_css("button[data-score='9'][aria-pressed='true']")
      expect(page).to have_text("9 - Amazing")
      click_button "Close"
    end
    within("#season_episodes") do
      expect(page).to have_css("button[aria-label='Edit your 9/10 rating for A Quiet Crossing']")
      expect(page).to have_css("[data-rating-button-target='badgeScore']", text: "9")
      find("button[aria-label='Edit your 9/10 rating for A Quiet Crossing']").click
    end
    expect(user.ratings.find_by!(item: episode).score).to eq(9)
    within("dialog[open]") do
      find("button[aria-label='Remove your 9/10 rating']").click
      expect(page).to have_text("Unrated")
      click_button "Close"
    end
    within("#season_episodes") do
      expect(page).to have_no_css("[data-rating-button-target='badgeScore']")
    end
    expect(user.ratings.exists?(item: episode)).to be(false)
  end

  scenario "rating a season from its poster on the show page" do
    season = FactoryBot.create(:season, :with_premiere_date)
    sign_in user
    visit show_path(season.show)

    within("#seasons") do
      find("button[aria-label='Rate #{season.translated_name}']").click
    end
    within("dialog[open]") do
      expect(page).to have_text(season.show.translated_title)
      expect(page).to have_text(season.translated_name)
      find("button[aria-label='Rate 8 out of 10']").click
      expect(page).to have_css("button[data-score='8'][aria-pressed='true']")
      click_button "Close"
    end
    within("#seasons") do
      expect(page).to have_css("button[aria-label='Edit your 8/10 rating for #{season.translated_name}']")
    end
  end

  scenario "rating a movie from its franchise poster" do
    movie = FactoryBot.create(:movie, :with_release_date)
    item = FactoryBot.create(:franchise_item, record: movie)
    sign_in user
    visit franchise_path(item.franchise)

    within("#franchise_items") do
      find("button[aria-label='Rate #{movie.translated_title}']").click
    end
    within("dialog[open]") do
      expect(page).to have_text(movie.translated_title)
      find("button[aria-label='Rate 10 out of 10']").click
      expect(page).to have_css("button[data-score='10'][aria-pressed='true']")
      click_button "Close"
    end
    within("#franchise_items") do
      expect(page).to have_css("button[aria-label='Edit your 10/10 rating for #{movie.translated_title}']")
    end
  end
end
