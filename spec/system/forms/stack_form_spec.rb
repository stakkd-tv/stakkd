# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Stack form", type: :system, js: true do
  scenario "Creating a new stack", :ignore_form_failures do
    user = FactoryBot.create(:user, :confirmed, username: "crxssed")
    FactoryBot.create(:stack, user:, name: "Amazing Stack")
    sign_in(user)

    visit user_path("me")
    expect(page).to have_content "crxssed"
    click_link "Stacks"
    expect(page).to have_css "a[data-active='true']", text: "Stacks"
    expect(page).to have_css "h6.font-domine", text: "Amazing Stack"

    find("a[href='#{new_user_stack_path(user)}']").click
    expect(page).to have_content "New stack"
    expect(page).not_to have_content "Amazing Stack"

    # Clicking cancel goes back to the stacks page
    click_link "Cancel"
    expect(page).to have_content "Amazing Stack"

    # Clicking new stack again
    find("a[href='#{new_user_stack_path(user)}']").click
    expect(page).to have_content "New stack"
    expect(page).not_to have_content "Amazing Stack"

    fill_in "Name", with: " "
    fill_in "Description", with: "This is a great stack"
    click_button "Save"

    # Still on the new stack page
    expect(page).to have_content "New stack"
    expect(page).to have_content "Name can't be blank"

    fill_in "Name", with: "Great Stack"
    click_button "Save"

    # Redirected to the stacks page
    expect(page).to have_css "h6.font-domine", text: "Amazing Stack"
    expect(page).to have_css "h6.font-domine", text: "Great Stack"
  end

  scenario "Accessing stacks for another user", :ignore_form_failures do
    user = FactoryBot.create(:user, :confirmed, username: "crxssed")
    FactoryBot.create(:stack, user:, name: "Amazing Stack")
    another_user = FactoryBot.create(:user, :confirmed, username: "another_user")
    sign_in(another_user)

    visit user_path(user)
    expect(page).to have_content "crxssed"
    click_link "Stacks"
    expect(page).to have_css "a[data-active='true']", text: "Stacks"
    expect(page).to have_css "h6.font-domine", text: "Amazing Stack"

    # New link is not available
    expect(page).not_to have_css "a[href='#{new_user_stack_path(user)}']"

    # Attempt to access the new stack page for the user
    visit new_user_stack_path(user)
    # Does not render a form
    expect(page).not_to have_css "input[name='stack[name]']"
    # We're on the profile page
    expect(page).to have_css "a[data-active='true']", text: "Profile"
  end
end
