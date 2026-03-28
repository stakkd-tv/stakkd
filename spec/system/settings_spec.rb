# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Settings", type: :system, js: true do
  before do
    @user = FactoryBot.create(:user, :confirmed)
    sign_in(@user)
  end

  scenario "Updating user settings", :ignore_form_failures do
    visit user_settings_path
    expect(page).to have_content("Your Settings")

    attach_file "user_profile_picture", Rails.root.join("spec/support/assets/400x400.png"), make_visible: true
    using_wait_time 5 do
      expect(page).to have_selector("#profile-picture-image[src*='data:image/png']")
    end

    attach_file "user_background", Rails.root.join("spec/support/assets/400x400.png"), make_visible: true
    using_wait_time 5 do
      expect(page).to have_selector("#background-image[src*='data:image/png']")
    end

    private_toggle = page.find("div[data-controller='toggle'][id='private'] div[data-toggle-target='toggleContainer']")
    private_toggle.click

    click_button "Save"
    expect(page).to have_content("Settings updated successfully.")

    @user.reload
    expect(@user.profile_picture).to be_attached
    expect(@user.background).to be_attached
    expect(@user.private).to be(true)
  end
end
