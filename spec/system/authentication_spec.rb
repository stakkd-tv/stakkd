# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Authentication", type: :system, js: true do
  before do
    FactoryBot.create(:user, email_address: "test@example.com", password: "top-secret")
  end

  scenario "User login, logout and sign up", :ignore_form_failures do
    visit root_path
    expect(page).to have_content("The open platform for movie and TV tracking")

    click_link "login-link"
    expect(page).to have_content("Welcome home!")

    # A failed attempt
    fill_in "email_address", with: "test@example.com"
    fill_in "password", with: "bogus"
    click_button "Enter"
    expect(page).to have_content("Sorry, but we couldn't find that account. Click the forgot password link if you've forgotten your password or get in touch if you think this is incorrect.")

    # Try again, with real credentials
    fill_in "password", with: "top-secret"
    click_button "Enter"
    expect(page).to have_css("div[data-nav-target='user']")
    expect(page).to have_content("Successfully logged in. Enjoy your stay!")
    flash_item_remove_button = find("i.fa-circle-xmark")
    flash_item_remove_button.click
    expect(page).not_to have_content("Successfully logged in. Enjoy your stay!")

    # Logout
    find("div[data-nav-target='user']").hover
    click_link "Sign out"

    expect(page).to have_content("Successfully logged out. Come back soon!")
    flash_item_remove_button = find("i.fa-circle-xmark")
    flash_item_remove_button.click
    expect(page).not_to have_content("Successfully logged out. Come back soon!")

    # Sign up
    click_link "join-link"
    expect(page).to have_content("Join the club")

    # A failed attempt
    fill_in "user_username", with: " "
    fill_in "user_email_address", with: "test@example.com"
    fill_in "user_password", with: "bye"
    fill_in "user_password_confirmation", with: "hello"
    click_button "Let's go!"
    expect(page).to have_content("Your account could not be created due to the following:")
    expect(page).to have_content("Username can't be blank")
    expect(page).to have_content("Email address has already been taken")
    expect(page).to have_content("Password confirmation doesn't match password")

    # A successful attempt
    fill_in "user_username", with: "obiwan"
    fill_in "user_email_address", with: "obi@example.com"
    fill_in "user_password", with: "top-secret"
    fill_in "user_password_confirmation", with: "top-secret"
    click_button "Let's go!"
    expect(page).to have_content("Success! You'll need to confirm your email before logging in.")

    # User can now login. TODO: This will change when confirmations are in place
    click_link "login-link"
    fill_in "email_address", with: "obi@example.com"
    fill_in "password", with: "top-secret"
    click_button "Enter"
    expect(page).to have_css("div[data-nav-target='user']")
    expect(page).to have_content("Successfully logged in. Enjoy your stay!")
    flash_item_remove_button = find("i.fa-circle-xmark")
    flash_item_remove_button.click
    expect(page).not_to have_content("Successfully logged in. Enjoy your stay!")
  end
end
