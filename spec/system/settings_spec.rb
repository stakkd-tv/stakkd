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

    bio_editor = page.find(".CodeMirror")
    bio_editor.click
    page.send_keys("**Markdown** is *sooooo* great!")

    private_toggle = page.find("div[data-controller='toggle'][id='private'] div[data-toggle-target='toggleContainer']")
    private_toggle.click

    click_button "Save"
    expect(page).to have_content("Settings updated successfully.")

    @user.reload
    expect(@user.profile_picture).to be_attached
    expect(@user.background).to be_attached
    expect(@user.biography).to eq "**Markdown** is *sooooo* great!"
    expect(@user.private).to be_truthy
  end

  scenario "Sanitizing markdown" do
    markdown = <<~MARKDOWN
      ||some spoiler text||
      <div align="center" class="bogus">Div centered</div>
      <p align="center" class="bogus">P centered</p>
      <img align="center" onerror="alert('error')" src="https://github.com/crxssed7.png"/>
      <center>Hello</center>
      <picture><source media="media" height="24px" onerror="alert('error')"></picture>
      <script>console.error('error')</script>
    MARKDOWN
    @user.update(biography: markdown)
    visit user_settings_path
    click_button "Toggle Preview (Ctrl-P)"
    expect(page).to have_css "div.rendered-markdown"
    within("div.rendered-markdown") do
      # Unsafe attributes are stripped, safe ones are kept
      expect(page).not_to have_css("[class='bogus']")
      expect(page).not_to have_css("[onerror]")
      expect(page).to have_css("span.spoiler", text: "some spoiler text")
      expect(page).to have_css("div[align='center']")
      expect(page).to have_css("p[align='center']")
      expect(page).to have_css("img[align='center'][src='https://github.com/crxssed7.png']")
      expect(page).to have_css("picture", visible: false)
      expect(page).to have_css("source[media='media']", visible: false)

      # Script tags are removed entirely
      expect(page).not_to have_css("script", visible: false)

      # Safe/expected content is rendered
      expect(page).to have_text("Hello")
      expect(page).to have_text("Div centered")
      expect(page).to have_text("P centered")

      # Ensure allowed structure still exists
      expect(page).to have_css("center", text: "Hello")
    end
  end
end
