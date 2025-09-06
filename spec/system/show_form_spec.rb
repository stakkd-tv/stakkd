# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Show form", type: :system, js: true do
  before do
    FactoryBot.create(:language)
    FactoryBot.create(:country, code: "GB", translated_name: "United Kingdom")

    user = FactoryBot.create(:user)
    sign_in(user)
  end

  scenario "Using the show form", :ignore_form_failures do
    visit shows_path
    expect(page).to have_content("Shows")

    # Details, TODO: Failures. Not urgent as failures are tested in request specs
    click_link "Add a show"
    fill_in "show_translated_title", with: "Test title"
    fill_in "show_original_title", with: "Original title"
    click_button "Save"
    expect(page).to have_content("Show was successfully created.")

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
  end
end
