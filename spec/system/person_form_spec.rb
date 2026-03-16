# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Person form", type: :system, js: true do
  before do
    user = FactoryBot.create(:user)
    sign_in(user)
  end

  scenario "Using the person form", :ignore_form_failures do
    visit people_path
    expect(page).to have_content("People")

    # Errors
    click_link "Add a person"
    fill_in "person_translated_name", with: " "
    fill_in "person_original_name", with: " "
    click_button "Save"
    expect(page).to have_content("Translated name can't be blank")
    expect(page).to have_content("Original name can't be blank")

    # Details
    fill_in "person_translated_name", with: "Test name"
    fill_in "person_original_name", with: "Original name"
    click_button "Save"
    expect(page).to have_content("Person was successfully created.")

    # Images
    click_link "Images"
    expect(page).to have_css("a[data-active='true']", text: "Images")
    expect(page).to have_content("Width must be between 300px and 2000px")
    attach_file "upload_input", [Rails.root.join("spec/support/assets/299x449.png"), Rails.root.join("spec/support/assets/300x450.png")]
    using_wait_time 5 do
      expect(page).to have_content("300x450.png uploaded")
      expect(page).to have_content("299x449.png: Width must be between 300px and 2000px, Height must be between 450px and 3000px")
    end
    expect(page).to have_css("img[src*='300x450.png']")
    expect(page).not_to have_css("img[src*='299x449.png']")
  end
end
