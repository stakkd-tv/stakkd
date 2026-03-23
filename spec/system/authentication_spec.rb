# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Authentication", type: :system, js: true do
  before do
    @user = FactoryBot.create(:user, :confirmed, email_address: "test@example.com", password: "top-secret")
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
    expect(page).to have_content("Sorry, but we couldn't find that account. Click the forgot password link if you've forgotten your password or request a new confirmation link if you have not yet confirmed your email address.")

    # Password reset
    click_link "Forgot your password?"
    expect(page).to have_content("Reset your password")
    fill_in "email_address", with: "test@example.com"
    click_button "Send instructions"
    expect(page).to have_content("Password reset instructions sent (if a confirmed user account with that email address exists).")
    # In the real world, user would access the reset link from their email
    visit edit_password_path(@user.password_reset_token)
    expect(page).to have_content("Reset your password")
    fill_in "password", with: "top-secret123"
    fill_in "password_confirmation", with: "top-secret123"
    click_button "Save"
    expect(page).to have_content("Password has been reset. You can now sign in.")

    # Try again, with real credentials
    expect(page).to have_content("Welcome home!")
    fill_in "email_address", with: "test@example.com"
    fill_in "password", with: "top-secret123"
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

    # Fail the trivia
    fill_in "user_username", with: "obiwan"
    fill_in "user_email_address", with: "obi@example.com"
    fill_in "user_password", with: "top-secret"
    fill_in "user_password_confirmation", with: "top-secret"
    trivia = page.find("input[name='trivia_question_name']", visible: false).value
    trivia_answer = UsersController::TRIVIA.find { it[:name] == trivia }[:answers].first
    fill_in "trivia_answer", with: "bogus answer"
    click_button "Let's go!"
    expect(page).to have_content("Bot accounts are not allowed.")

    # A failed attempt
    fill_in "user_username", with: " "
    fill_in "user_email_address", with: "test@example.com"
    fill_in "user_password", with: "bye"
    fill_in "user_password_confirmation", with: "hello"
    fill_in "trivia_answer", with: trivia_answer # Trivia is persisted across requests
    click_button "Let's go!"
    expect(page).to have_content("Username can't be blank")
    expect(page).to have_content("Email address has already been taken")
    expect(page).to have_content("Password confirmation doesn't match password")

    # A successful attempt
    fill_in "user_username", with: "obiwan"
    fill_in "user_email_address", with: "obi@example.com"
    fill_in "user_password", with: "top-secret"
    fill_in "user_password_confirmation", with: "top-secret"
    fill_in "trivia_answer", with: trivia_answer # Trivia is persisted across requests
    click_button "Let's go!"
    expect(page).to have_content("Success! You'll need to confirm your email before logging in.")

    # User can't log in yet - they need to confirm their account
    click_link "login-link"
    fill_in "email_address", with: "obi@example.com"
    fill_in "password", with: "top-secret"
    click_button "Enter"
    expect(page).to have_content("Sorry, but we couldn't find that account. Click the forgot password link if you've forgotten your password or request a new confirmation link if you have not yet confirmed your email address.")

    # Confirm the user's account
    confirmation_token = ConfirmationToken.last
    # In the real world, user will access this link for the email
    visit confirm_users_path(token: confirmation_token.token)
    expect(page).to have_content "Successfully confirmed your account, you can now login!"

    # Now the user can log in
    fill_in "email_address", with: "obi@example.com"
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

    # Resend confirmation email
    click_link "login-link"
    expect(page).to have_content("Welcome home!")
    click_link "Resend confirmation email"
    expect(page).to have_content("Resend confirmation email")
    fill_in "email_address", with: "obi@example.com"
    click_button "Resend email"
    expect(page).to have_content("A confirmation email has been resent to your email (if a user was found with that email address).")
  end
end
