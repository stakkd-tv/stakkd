# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Stack actions", type: :system, js: true do
  scenario "deleting stack from user page" do
    user = FactoryBot.create(:user, :confirmed, email_address: "test@example.com", password: "top-secret")
    stack = FactoryBot.create(:stack, user:, name: "Amazing Stack")

    # User being viewed is not the same as the current user, so more stack options not shown
    visit user_path(user)
    expect(page).not_to have_css "button#Stack_#{stack.id}_more_options"

    sign_in(user)
    # User is now the same as the current user
    visit user_path(user)
    expect(page).to have_css "button#Stack_#{stack.id}_more_options"

    expect(page).to have_content "Amazing Stack"
    click_button "Stack_#{stack.id}_more_options"
    expect(page).to have_button "Delete"
    click_button "Delete"
    expect(page).to have_content "Are you sure you want to delete this?"
    click_button "No"
    # Does not delete the stack when clicking No
    expect(page).not_to have_content "Are you sure you want to delete this?"
    expect(page).to have_content "Amazing Stack"
    expect(Stack.count).to eq 1

    click_button "Stack_#{stack.id}_more_options"
    expect(page).to have_button "Delete"
    click_button "Delete"
    expect(page).to have_content "Are you sure you want to delete this?"
    click_button "Yes"
    # Stack is now deleted
    expect(page).not_to have_content "Are you sure you want to delete this?"
    expect(page).not_to have_content "Amazing Stack"
    expect(Stack.count).to eq 0
  end

  scenario "deleting stack from stacks page" do
    user = FactoryBot.create(:user, :confirmed, email_address: "test@example.com", password: "top-secret")
    stack = FactoryBot.create(:stack, user:, name: "Amazing Stack")

    # User being viewed is not the same as the current user, so more stack options not shown
    visit user_stacks_path(user)
    expect(page).not_to have_css "button#Stack_#{stack.id}_more_options"

    sign_in(user)
    # User is now the same as the current user
    visit user_stacks_path(user)
    expect(page).to have_css "button#Stack_#{stack.id}_more_options"

    expect(page).to have_content "Amazing Stack"
    click_button "Stack_#{stack.id}_more_options"
    expect(page).to have_button "Delete"
    click_button "Delete"
    expect(page).to have_content "Are you sure you want to delete this?"
    click_button "No"
    # Does not delete the stack when clicking No
    expect(page).not_to have_content "Are you sure you want to delete this?"
    expect(page).to have_content "Amazing Stack"
    expect(Stack.count).to eq 1

    click_button "Stack_#{stack.id}_more_options"
    expect(page).to have_button "Delete"
    click_button "Delete"
    expect(page).to have_content "Are you sure you want to delete this?"
    click_button "Yes"
    # Stack is now deleted
    expect(page).not_to have_content "Are you sure you want to delete this?"
    expect(page).not_to have_content "Amazing Stack"
    expect(Stack.count).to eq 0
  end
end
