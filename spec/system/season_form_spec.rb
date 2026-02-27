# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Show form", type: :system, js: true do
  before do
    @show = FactoryBot.create(:show)

    user = FactoryBot.create(:user)
    sign_in(user)
  end

  scenario "Using the season form", :ignore_form_failures do
    visit show_path(@show)
    expect(page).to have_content(@show.translated_title)

    # Details, TODO: Failures. Not urgent as failures are tested in request specs
    click_link "Add Season"
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
  end
end
