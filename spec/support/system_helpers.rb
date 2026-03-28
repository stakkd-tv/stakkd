# frozen_string_literal: true

module SystemHelpers
  def sign_in(user)
    visit new_session_path
    fill_in "email_address", with: user.email_address
    fill_in "password", with: user.password
    click_button "Enter"
    expect(page).to have_content "Successfully logged in. Enjoy your stay!"
  end
end
