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

  scenario "editing a stack from the stack page", ignore_form_failures: true do
    user = FactoryBot.create(:user, :confirmed)
    stack = FactoryBot.create(:stack, user:, name: "Amazing Stack", description: "This is an amazing stack", sorting_method: "added_at")

    # Not logged in as the stacks user
    another_user = FactoryBot.create(:user, :confirmed)
    sign_in(another_user)
    visit user_stack_path(stack, user_id: user)

    # Edit button is not on page
    expect(page).not_to have_css "button[data-controller='edit-stack-button']"

    # Sign in as stack user, edit button on page
    sign_in(user)
    visit user_stack_path(stack, user_id: user)
    expect(page).to have_css "button[data-controller='edit-stack-button']"

    # Open edit stack dialog
    find("button[data-controller='edit-stack-button']").click
    expect(page).to have_css "dialog[data-controller='edit-stack-dialog']"

    # Inputs are prefilled, inside form
    expect(page).to have_css "form[action='#{user_stack_path(stack, user_id: user)}']"
    expect(find("input[name='stack[name]']").value).to eq "Amazing Stack"
    expect(find("textarea[name='stack[description]']").value).to eq "This is an amazing stack"
    expect(find("select[name='stack[sorting_method]']").value).to eq "added_at"
    expect(find("select[name='stack[sorting_direction]']").value).to eq "asc"
    expect(page).to have_css "#stack_private[data-controller='toggle'][data-checked='false']"

    # Saving in an invalid state
    fill_in "stack[name]", with: " "
    fill_in "stack[description]", with: "This description is too long to be a description... descriptions cannot be over 100 characters long..."
    select "Position", from: "stack[sorting_method]"
    select "Desc", from: "stack[sorting_direction]"
    private_toggle = page.find("div[data-controller='toggle'][id='stack_private'] div[data-toggle-target='toggleContainer']")
    private_toggle.click
    expect(page).to have_css "#stack_private[data-controller='toggle'][data-checked='true']"
    click_button "Confirm"
    expect(page).to have_css "input[name='stack[name]'][data-field-error='true']"
    expect(page).to have_css "textarea[name='stack[description]'][data-field-error='true']"
    expect(page).to have_content "Name can't be blank"
    expect(page).to have_content "Description is too long (maximum is 100 characters)"

    # Closing the dialog resets all inputs
    click_button "Cancel"
    find("button[data-controller='edit-stack-button']").click
    expect(page).to have_css "dialog[data-controller='edit-stack-dialog']"
    expect(page).to have_css "form[action='#{user_stack_path(stack, user_id: user)}']"
    expect(find("input[name='stack[name]']").value).to eq "Amazing Stack"
    expect(find("textarea[name='stack[description]']").value).to eq "This is an amazing stack"
    expect(find("select[name='stack[sorting_method]']").value).to eq "added_at"
    expect(find("select[name='stack[sorting_direction]']").value).to eq "asc"
    expect(page).to have_css "#stack_private[data-controller='toggle'][data-checked='false']"
    expect(page).not_to have_css "input[name='stack[name]'][data-field-error='true']"
    expect(page).not_to have_css "textarea[name='stack[description]'][data-field-error='true']"
    expect(page).not_to have_content "Name can't be blank"
    expect(page).not_to have_content "Description is too long (maximum is 100 characters)"

    # Fill in with valid attributes, updates the DOM
    fill_in "stack[name]", with: "NEW AND UPDATED STACK!"
    fill_in "stack[description]", with: "I have just updated this stack"
    select "Position", from: "stack[sorting_method]"
    select "Desc", from: "stack[sorting_direction]"
    private_toggle = page.find("div[data-controller='toggle'][id='stack_private'] div[data-toggle-target='toggleContainer']")
    private_toggle.click
    expect(page).to have_css "#stack_private[data-controller='toggle'][data-checked='true']"
    click_button "Confirm"
    expect(page).not_to have_content "Amazing Stack"
    expect(page).to have_content "NEW AND UPDATED STACK!"
    expect(page).not_to have_content "This is an amazing stack"
    expect(page).to have_content "I have just updated this stack"

    # Open the dialog again, pre-fills with updated attributes
    find("button[data-controller='edit-stack-button']").click
    expect(page).to have_css "dialog[data-controller='edit-stack-dialog']"
    expect(page).to have_css "form[action='#{user_stack_path(stack, user_id: user)}']"
    expect(find("input[name='stack[name]']").value).to eq "NEW AND UPDATED STACK!"
    expect(find("textarea[name='stack[description]']").value).to eq "I have just updated this stack"
    expect(find("select[name='stack[sorting_method]']").value).to eq "position"
    expect(find("select[name='stack[sorting_direction]']").value).to eq "desc"
    expect(page).to have_css "#stack_private[data-controller='toggle'][data-checked='true']"
  end

  scenario "editing a stack from the user stacks index page" do
    user = FactoryBot.create(:user, :confirmed)
    stack1 = FactoryBot.create(:stack, user:, name: "Amazing Stack", description: "This is an amazing stack", private: false)
    stack2 = FactoryBot.create(:stack, user:, name: "Private Stack", description: "This is an private stack", private: true)

    sign_in user
    visit user_stacks_path(user)

    expect(page).to have_css "p", text: "Only you can see this stack", count: 1

    # Pre-filled for stack 1
    find("#Stack_#{stack1.id}_more_options").click
    find("button[data-edit-stack-button-stack-id-value='#{stack1.id}']").click
    expect(page).to have_css "dialog[data-controller='edit-stack-dialog']"
    expect(page).to have_css "form[action='#{user_stack_path(stack1, user_id: user)}']"
    expect(find("input[name='stack[name]']").value).to eq "Amazing Stack"
    expect(find("textarea[name='stack[description]']").value).to eq "This is an amazing stack"
    expect(find("select[name='stack[sorting_method]']").value).to eq "added_at"
    expect(find("select[name='stack[sorting_direction]']").value).to eq "asc"
    expect(page).to have_css "#stack_private[data-controller='toggle'][data-checked='false']"
    click_button "Cancel"

    # Pre-filled for stack 2
    find("#Stack_#{stack2.id}_more_options").click
    find("button[data-edit-stack-button-stack-id-value='#{stack2.id}']").click
    expect(page).to have_css "dialog[data-controller='edit-stack-dialog']"
    expect(page).to have_css "form[action='#{user_stack_path(stack2, user_id: user)}']"
    expect(find("input[name='stack[name]']").value).to eq "Private Stack"
    expect(find("textarea[name='stack[description]']").value).to eq "This is an private stack"
    expect(find("select[name='stack[sorting_method]']").value).to eq "added_at"
    expect(find("select[name='stack[sorting_direction]']").value).to eq "asc"
    expect(page).to have_css "#stack_private[data-controller='toggle'][data-checked='true']"
    click_button "Cancel"

    # Edit stack 1
    find("#Stack_#{stack1.id}_more_options").click
    find("button[data-edit-stack-button-stack-id-value='#{stack1.id}']").click
    expect(page).to have_css "dialog[data-controller='edit-stack-dialog']"
    fill_in "stack[name]", with: "New name"
    private_toggle = page.find("div[data-controller='toggle'][id='stack_private'] div[data-toggle-target='toggleContainer']")
    private_toggle.click
    click_button "Confirm"
    expect(page).not_to have_content "Amazing Stack"
    expect(page).to have_content "New name"
    expect(page).to have_css "p", text: "Only you can see this stack", count: 2
  end

  scenario "deleting stack item from stack page" do
    user = FactoryBot.create(:user, :confirmed, email_address: "test@example.com", password: "top-secret")
    stack = FactoryBot.create(:stack, user:, name: "Amazing Stack")
    movie = FactoryBot.create(:movie, translated_title: "Amazing Movie")
    stack_item = FactoryBot.create(:stack_item, stack:, item: movie)

    # User being viewed is not the same as the current user, so can't delete stack item
    visit user_stack_path(stack, user_id: user)
    expect(page).not_to have_css "button[data-deletion-button-delete-record-url-value='#{user_stack_stack_item_path(stack_item, stack_id: stack, user_id: user)}']"

    sign_in(user)
    # User is now the same as the current user
    visit user_stack_path(stack, user_id: user)
    expect(page).to have_css "button[data-deletion-button-delete-record-url-value='#{user_stack_stack_item_path(stack_item, stack_id: stack, user_id: user)}']"

    expect(page).to have_content "Amazing Movie"
    find("button[data-deletion-button-delete-record-url-value='#{user_stack_stack_item_path(stack_item, stack_id: stack, user_id: user)}']").click
    expect(page).to have_content "Are you sure you want to delete this?"
    click_button "No"
    # Does not delete the stack item when clicking No
    expect(page).not_to have_content "Are you sure you want to delete this?"
    expect(page).to have_content "Amazing Movie"
    expect(StackItem.count).to eq 1

    find("button[data-deletion-button-delete-record-url-value='#{user_stack_stack_item_path(stack_item, stack_id: stack, user_id: user)}']").click
    expect(page).to have_content "Are you sure you want to delete this?"
    click_button "Yes"
    # Stack item is now deleted
    expect(page).not_to have_content "Are you sure you want to delete this?"
    expect(page).not_to have_content "Amazing Movie"
    expect(StackItem.count).to eq 0
  end
end
