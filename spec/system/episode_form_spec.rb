# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Show form", type: :system, js: true do
  before do
    @show = FactoryBot.create(:show)
    @season = @show.seasons.first

    user = FactoryBot.create(:user)
    sign_in(user)
  end

  scenario "Using the season form", :ignore_form_failures do
    visit show_season_path(@show, @season)
    expect(page).to have_content(@season.translated_name)

    # Details, TODO: Failures. Not urgent as failures are tested in request specs
    click_link "New episode"
    fill_in "episode_translated_name", with: "Test name"
    fill_in "episode_original_name", with: "Original name"
    fill_in "episode_number", with: "1"
    click_button "Save"
    expect(page).to have_content("Episode was successfully created.")
    episode = Episode.last

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
  end
end
