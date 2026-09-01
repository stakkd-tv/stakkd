# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Episode actions", type: :system, js: true do
  include ActiveSupport::Testing::TimeHelpers

  before do
    travel_to Date.new(2026, 8, 13)
    @user = FactoryBot.create(:user, :confirmed, email_address: "test@example.com", password: "top-secret")
    @episode = FactoryBot.create(:episode, original_air_date: nil)
  end

  def remove_from_history(episode = nil, expected_history_count: 0)
    episode ||= @episode
    open_add_to_history_dialog(episode)
    expect(page).to have_css "dialog[data-controller='history-dialog']"
    click_button "Clear history"
    expect(page).not_to have_css "dialog[data-controller='history-dialog']"
    expect(page).to have_css "button[data-controller='history-button'][data-record-type='Episode'][data-record-id='#{episode.id}'][data-status='not_consumed']"
    expect(@user.history_items.count).to eq expected_history_count
  end

  def open_add_to_history_dialog(episode = nil)
    episode ||= @episode
    find("button[title='Add to history'][data-record-type='Episode'][data-record-id='#{episode.id}']").click
  end

  scenario "adding to and removing from history from the episode page" do
    visit show_season_episode_path(@episode, show_id: @episode.show, season_id: @episode.season)
    expect(page).to have_content @episode.translated_name

    # Not signed in, so add to history button is not on the page
    expect(page).not_to have_css "button[data-controller='history-button'][data-record-type='Episode'][data-record-id='#{@episode.id}']"

    sign_in @user
    visit show_season_episode_path(@episode, show_id: @episode.show, season_id: @episode.season)
    expect(page).to have_content @episode.translated_name

    # Now signed in, add to history button is on the page, not consumed state
    expect(page).to have_css "button[data-controller='history-button'][data-record-type='Episode'][data-record-id='#{@episode.id}'][data-status='not_consumed']"

    # Episode has not been released, add to history is disabled
    expect(page).to have_css "button[data-controller='history-button'][data-record-type='Episode'][data-record-id='#{@episode.id}'][disabled]"

    # Episode is now released
    @episode.update(original_air_date: Date.today)
    page.refresh

    # History dialog is not shown
    expect(page).not_to have_css "dialog[data-controller='history-dialog']"

    open_add_to_history_dialog

    # History dialog is shown with a form for adding to history
    expect(page).to have_css "dialog[data-controller='history-dialog']"
    within "dialog[data-controller='history-dialog']" do
      expect(page).to have_css "form[action='#{add_to_history_show_season_episode_path(@episode, show_id: @episode.show, season_id: @episode.season)}']"
    end

    # Choosing now option
    click_button "Now"
    expect(page).to have_css "button[data-option='now'][data-active='true']"
    click_button "Confirm"
    # Dialog is now hidden
    expect(page).not_to have_css "dialog[data-controller='history-dialog']"
    # Add to history button state is updated
    expect(page).to have_css "button[data-controller='history-button'][data-record-type='Episode'][data-record-id='#{@episode.id}'][data-status='consumed']"
    expect(@user.history_items.count).to eq 1
    expect(@user.history_items.first.item).to eq @episode
    expect(@user.history_items.first.consumed_at).to eq Time.current
    remove_from_history

    # Choosing release date option
    open_add_to_history_dialog
    expect(page).to have_css "dialog[data-controller='history-dialog']"
    click_button "Release date"
    expect(page).to have_css "button[data-option='release_date'][data-active='true']"
    click_button "Confirm"
    # Dialog is now hidden
    expect(page).not_to have_css "dialog[data-controller='history-dialog']"
    # Add to history button state is updated
    expect(page).to have_css "button[data-controller='history-button'][data-record-type='Episode'][data-record-id='#{@episode.id}'][data-status='consumed']"
    expect(@user.history_items.count).to eq 1
    expect(@user.history_items.first.item).to eq @episode
    expect(@user.history_items.first.consumed_at).to eq Date.today.beginning_of_day
    remove_from_history

    # Choosing other date option
    open_add_to_history_dialog
    expect(page).to have_css "dialog[data-controller='history-dialog']"
    expect(page).not_to have_css "input#consumed_at"
    click_button "Other date"
    expect(page).to have_css "button[data-option='date'][data-active='true']"
    expect(page).to have_css "input#consumed_at"
    page.find("input#consumed_at").click
    expect(page).to have_css ".flatpickr-calendar"
    # We need to pick the specific month and year as travel_to does not affect client side JS
    page.find("select.flatpickr-monthDropdown-months").select("August")
    page.find("input[aria-label='Year']").fill_in(with: "2026")
    page.find("span.flatpickr-day", text: "14").click
    page.find("input.flatpickr-hour").fill_in(with: "13")
    page.find("input.flatpickr-minute").fill_in(with: "05")
    click_button "Confirm"
    # Dialog is now hidden
    expect(page).not_to have_css "dialog[data-controller='history-dialog']"
    # Add to history button state is updated
    expect(page).to have_css "button[data-controller='history-button'][data-record-type='Episode'][data-record-id='#{@episode.id}'][data-status='consumed']"
    expect(@user.history_items.count).to eq 1
    expect(@user.history_items.first.item).to eq @episode
    expect(@user.history_items.first.consumed_at).to eq DateTime.new(2026, 8, 14, 13, 5)
    remove_from_history

    # Choosing unknown
    open_add_to_history_dialog
    expect(page).to have_css "dialog[data-controller='history-dialog']"
    click_button "Unknown"
    expect(page).to have_css "button[data-option='unknown'][data-active='true']"
    click_button "Confirm"
    # Dialog is now hidden
    expect(page).not_to have_css "dialog[data-controller='history-dialog']"
    # Add to history button state is updated
    expect(page).to have_css "button[data-controller='history-button'][data-record-type='Episode'][data-record-id='#{@episode.id}'][data-status='consumed']"
    expect(@user.history_items.count).to eq 1
    expect(@user.history_items.first.item).to eq @episode
    expect(@user.history_items.first.consumed_at).to be_nil
    remove_from_history

    # Clicking cancel closes the dialog
    open_add_to_history_dialog
    expect(page).to have_css "dialog[data-controller='history-dialog']"
    click_button "Cancel"
    expect(page).not_to have_css "dialog[data-controller='history-dialog']"
    # Does not add any history items
    expect(@user.history_items.count).to eq 0
  end

  scenario "add to and removing from history from the season page" do
    @episode.update!(original_air_date: Date.today)
    episode2 = FactoryBot.create(:episode, season: @episode.season, number: @episode.number + 1, original_air_date: Date.today)
    episode3 = FactoryBot.create(:episode, season: @episode.season, number: @episode.number + 2, original_air_date: nil)
    sign_in @user

    visit show_season_path(@episode.season, show_id: @episode.show)
    expect(page).to have_content "Season #{@episode.season.number}"

    # Season is not consumed at all
    expect(page).to have_css "button[data-controller='history-button'][data-record-type='Season'][data-record-id='#{@episode.season.id}'][data-status='not_consumed']"

    # Episode 3 has not been released, so its add to history button is disabled
    expect(page).to have_css "button[data-controller='history-button'][data-record-type='Episode'][data-record-id='#{episode3.id}'][disabled]"

    # Adding episode 1 to history
    open_add_to_history_dialog
    click_button "Confirm"
    # Dialog is now hidden
    expect(page).not_to have_css "dialog[data-controller='history-dialog']"
    # Add to history button state is updated
    expect(page).to have_css "button[data-controller='history-button'][data-record-type='Episode'][data-record-id='#{@episode.id}'][data-status='consumed']"
    expect(@user.history_items.count).to eq 1
    expect(@user.history_items.first.item).to eq @episode
    expect(@user.history_items.first.consumed_at).to eq Time.current
    # The season is now partially consumed
    expect(page).to have_css "button[data-controller='history-button'][data-record-type='Season'][data-record-id='#{@episode.season.id}'][data-status='partially_consumed']"

    # Adding episode 2 to history
    open_add_to_history_dialog(episode2)
    click_button "Confirm"
    # Dialog is now hidden
    expect(page).not_to have_css "dialog[data-controller='history-dialog']"
    # Add to history button state is updated
    expect(page).to have_css "button[data-controller='history-button'][data-record-type='Episode'][data-record-id='#{episode2.id}'][data-status='consumed']"
    expect(@user.history_items.count).to eq 2
    expect(@user.history_items.second.item).to eq episode2
    expect(@user.history_items.first.consumed_at).to eq Time.current
    # The season is now fully consumed as episode 3 is not yet released
    expect(page).to have_css "button[data-controller='history-button'][data-record-type='Season'][data-record-id='#{@episode.season.id}'][data-status='consumed']"

    # Removing episode 1 from history
    remove_from_history(expected_history_count: 1) # Episode 2 is still consumed, history count is 1
    # Season is now partially consumed as only episode 2 is consumed
    expect(page).to have_css "button[data-controller='history-button'][data-record-type='Season'][data-record-id='#{@episode.season.id}'][data-status='partially_consumed']"

    # Removing episode 2 from history
    remove_from_history(episode2)
    # Season is now not consumed as no episodes are consumed
    expect(page).to have_css "button[data-controller='history-button'][data-record-type='Season'][data-record-id='#{@episode.season.id}'][data-status='not_consumed']"
  end

  scenario "adding to and removing from stacks" do
    stack1 = FactoryBot.create(:stack, user: @user, name: "Amazing Stack")
    stack2 = FactoryBot.create(:stack, user: @user, name: "Great Stack")

    # Not signed in, so actions are not available
    expect(page).not_to have_css "button[title='More options']"

    sign_in @user
    visit show_season_episode_path(@episode, season_id: @episode.season, show_id: @episode.show)
    expect(page).to have_content @episode.translated_name

    # Now signed in, actions are available
    expect(page).to have_css "button[title='More options']"

    # Dialog is not shown
    expect(page).not_to have_css "dialog[data-controller='stack-dialog']"

    click_button "Episode_#{@episode.id}_more_options"
    click_button "Add to stack"

    # Dialog is now shown
    expect(page).to have_css "dialog[data-controller='stack-dialog']"

    # Adding to 'Amazing Stack'
    click_button "Amazing Stack"
    expect(page).to have_css "button[data-stack-id='#{stack1.id}'][data-active='true']"
    expect(StackItem.count).to eq 1

    # Adding to 'Great Stack'
    click_button "Great Stack"
    expect(page).to have_css "button[data-stack-id='#{stack2.id}'][data-active='true']"
    expect(StackItem.count).to eq 2

    # Close the dialog
    click_button "Close"

    # Open the dialog again
    click_button "Episode_#{@episode.id}_more_options"
    click_button "Add to stack"
    # Counts are updated
    expect(page).to have_css "small[data-stack-button-target='stackCount']", text: "2"

    # The stacks are still in active state
    expect(page).to have_css "button[data-stack-id='#{stack1.id}'][data-active='true']"
    expect(page).to have_css "button[data-stack-id='#{stack2.id}'][data-active='true']"

    # Removing from 'Amazing Stack'
    click_button "Amazing Stack"
    expect(page).to have_css "button[data-stack-id='#{stack1.id}'][data-active='false']"
    expect(StackItem.count).to eq 1

    # Removing from 'Great Stack'
    click_button "Great Stack"
    expect(page).to have_css "button[data-stack-id='#{stack2.id}'][data-active='false']"
    expect(StackItem.count).to eq 0

    # Creating a stack and adding it
    fill_in "stack_name", with: "   "
    click_button "Create and add"
    # It does not add a stack with an empty name
    expect(page).to have_css "button[data-stack-id]", count: 2

    fill_in "stack_name", with: "Bad Stack"
    click_button "Create and add"
    expect(page).to have_css "button[data-stack-id]", count: 3
    new_stack = Stack.last
    expect(new_stack.name).to eq "Bad Stack"
    expect(new_stack.stack_items.count).to eq 1
    expect(page).to have_css "button[data-stack-id='#{new_stack.id}'][data-active='true']"

    # Close the dialog
    click_button "Close"

    # Open the dialog again
    click_button "Episode_#{@episode.id}_more_options"
    click_button "Add to stack"

    # New stack is still there, that is active
    expect(page).to have_css "button[data-stack-id='#{new_stack.id}'][data-active='true']"

    # Remove from 'Bad Stack'
    click_button "Bad Stack"
    expect(page).to have_css "button[data-stack-id='#{new_stack.id}'][data-active='false']"
    expect(StackItem.count).to eq 0

    click_button "Close"
    click_button "Episode_#{@episode.id}_more_options"
    # Counts are updated
    expect(page).to have_css "small[data-stack-button-target='stackCount']", text: "0", visible: false
  end
end
