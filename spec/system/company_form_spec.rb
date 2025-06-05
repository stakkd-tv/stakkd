# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Company form", type: :system, js: true do
  before do
    FactoryBot.create(:country)
    user = FactoryBot.create(:user)
    sign_in(user)
  end

  scenario "Using the company form", :ignore_form_failures do
    visit companies_path
    expect(page).to have_content("Companies")

    # Details, TODO: Failures. Not urgent as failures are tested in request specs
    click_link "Add a company"
    fill_in "company_name", with: "Test company"
    fill_in "company_description", with: "Test description"
    fill_in "company_homepage", with: "https://example.com"
    click_button "Save"
    expect(page).to have_content("Company was successfully created.")

    # Logos
    click_link "Logos"
    attach_file "upload_input", [Rails.root.join("spec/support/assets/400x400.png"), Rails.root.join("spec/support/assets/399x399.png")]
    expect(page).to have_content("Uploading 400x400.png...")
    expect(page).to have_content("Uploading 399x399.png...")
    using_wait_time 5 do
      expect(page).to have_content("400x400.png uploaded")
      expect(page).to have_content("399x399.png: Width must be between 400px and 3000px, Height must be between 400px and 3000px")
    end
    expect(page).to have_css("img[src*='400x400.png']")
    expect(page).not_to have_css("img[src*='399x399.png']")
  end
end
