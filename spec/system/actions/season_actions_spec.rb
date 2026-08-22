# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Season actions", type: :system, js: true do
  include ActiveSupport::Testing::TimeHelpers

  before do
    travel_to Date.new(2026, 8, 13)
    @user = FactoryBot.create(:user, :confirmed, email_address: "test@example.com", password: "top-secret")
    @season = FactoryBot.create(:season, number: 1)
  end

  def remove_from_history(season = nil, expected_history_count: 0)
    season ||= @season
    open_add_to_history_dialog(season)
    expect(page).to have_css "dialog[data-controller='history-dialog']"
    click_button "Clear history"
    expect(page).not_to have_css "dialog[data-controller='history-dialog']"
    expect(page).to have_css "button[data-controller='history-button'][data-record-type='Season'][data-record-id='#{season.id}'][data-status='not_consumed']"
    expect(@user.history_items.count).to eq expected_history_count
  end

  def open_add_to_history_dialog(season = nil)
    season ||= @season
    find("button[title='Add to history'][data-record-type='Season'][data-record-id='#{season.id}']").click
  end

  scenario "adding to and removing from history from the season page" do
    visit show_season_path(@season, show_id: @season.show)
    expect(page).to have_content "Season #{@season.number}"

    # Not signed in, so add to history button is not on the page
    expect(page).not_to have_css "button[data-controller='history-button'][data-record-type='Season'][data-record-id='#{@season.id}']"

    sign_in @user
    visit show_season_path(@season, show_id: @season.show)
    expect(page).to have_content "Season #{@season.number}"

    # Now signed in, add to history button is on the page, not consumed state
    expect(page).to have_css "button[data-controller='history-button'][data-record-type='Season'][data-record-id='#{@season.id}'][data-status='not_consumed']"

    # Season has not been released, add to history is disabled
    expect(page).to have_css "button[data-controller='history-button'][data-record-type='Season'][data-record-id='#{@season.id}'][disabled]"

    # Season is now released
    episode = FactoryBot.create(:episode, number: 1, original_air_date: Date.today, season: @season)
    unreleased_episode = FactoryBot.create(:episode, number: 2, original_air_date: nil, season: @season)
    page.refresh

    # History dialog is not shown
    expect(page).not_to have_css "dialog[data-controller='history-dialog']"

    # Episode add to history is shown, in an unconsumed state
    expect(page).to have_css "button[data-controller='history-button'][data-record-type='Episode'][data-record-id='#{episode.id}'][data-status='not_consumed']"
    expect(page).to have_css "button[data-controller='history-button'][data-record-type='Episode'][data-record-id='#{unreleased_episode.id}'][data-status='not_consumed'][disabled]"

    open_add_to_history_dialog

    # History dialog is shown with a form for adding to history
    expect(page).to have_css "dialog[data-controller='history-dialog']"
    within "dialog[data-controller='history-dialog']" do
      expect(page).to have_css "form[action='#{add_to_history_show_season_path(@season, show_id: @season.show)}']"
    end

    # Choosing now option
    click_button "Now"
    expect(page).to have_css "button[data-option='now'][data-active='true']"
    click_button "Confirm"
    # Dialog is now hidden
    expect(page).not_to have_css "dialog[data-controller='history-dialog']"
    # Add to history button state is updated
    expect(page).to have_css "button[data-controller='history-button'][data-record-type='Season'][data-record-id='#{@season.id}'][data-status='consumed']"
    expect(@user.history_items.count).to eq 1
    expect(@user.history_items.first.item).to eq episode
    expect(@user.history_items.first.consumed_at).to eq Time.current
    # Episode add to history button state is updated
    expect(page).to have_css "button[data-controller='history-button'][data-record-type='Episode'][data-record-id='#{episode.id}'][data-status='consumed']"
    # Unreleased episode does not have its state updated
    expect(page).to have_css "button[data-controller='history-button'][data-record-type='Episode'][data-record-id='#{unreleased_episode.id}'][data-status='not_consumed'][disabled]"
    remove_from_history
    # Episode add to history button state is updated, now unconsumed
    expect(page).to have_css "button[data-controller='history-button'][data-record-type='Episode'][data-record-id='#{episode.id}'][data-status='not_consumed']"
    # Unreleased episode does not have its state updated
    expect(page).to have_css "button[data-controller='history-button'][data-record-type='Episode'][data-record-id='#{unreleased_episode.id}'][data-status='not_consumed'][disabled]"

    # Choosing release date option
    open_add_to_history_dialog
    expect(page).to have_css "dialog[data-controller='history-dialog']"
    click_button "Release date"
    expect(page).to have_css "button[data-option='release_date'][data-active='true']"
    click_button "Confirm"
    # Dialog is now hidden
    expect(page).not_to have_css "dialog[data-controller='history-dialog']"
    # Add to history button state is updated
    expect(page).to have_css "button[data-controller='history-button'][data-record-type='Season'][data-record-id='#{@season.id}'][data-status='consumed']"
    expect(@user.history_items.count).to eq 1
    expect(@user.history_items.first.item).to eq episode
    expect(@user.history_items.first.consumed_at).to eq Date.today.beginning_of_day
    # Episode add to history button state is updated
    expect(page).to have_css "button[data-controller='history-button'][data-record-type='Episode'][data-record-id='#{episode.id}'][data-status='consumed']"
    # Unreleased episode does not have its state updated
    expect(page).to have_css "button[data-controller='history-button'][data-record-type='Episode'][data-record-id='#{unreleased_episode.id}'][data-status='not_consumed'][disabled]"
    remove_from_history
    # Episode add to history button state is updated, now unconsumed
    expect(page).to have_css "button[data-controller='history-button'][data-record-type='Episode'][data-record-id='#{episode.id}'][data-status='not_consumed']"
    # Unreleased episode does not have its state updated
    expect(page).to have_css "button[data-controller='history-button'][data-record-type='Episode'][data-record-id='#{unreleased_episode.id}'][data-status='not_consumed'][disabled]"

    # Choosing other date option
    open_add_to_history_dialog
    expect(page).to have_css "dialog[data-controller='history-dialog']"
    expect(page).not_to have_css "input#consumed_at"
    click_button "Other date"
    expect(page).to have_css "button[data-option='date'][data-active='true']"
    expect(page).to have_css "input#consumed_at"
    page.find("input#consumed_at").click
    expect(page).to have_css ".flatpickr-calendar"
    page.find("span.flatpickr-day", text: "14").click
    page.find("input.flatpickr-hour").fill_in(with: "13")
    page.find("input.flatpickr-minute").fill_in(with: "05")
    click_button "Confirm"
    # Dialog is now hidden
    expect(page).not_to have_css "dialog[data-controller='history-dialog']"
    # Add to history button state is updated
    expect(page).to have_css "button[data-controller='history-button'][data-record-type='Season'][data-record-id='#{@season.id}'][data-status='consumed']"
    expect(@user.history_items.count).to eq 1
    expect(@user.history_items.first.item).to eq episode
    expect(@user.history_items.first.consumed_at).to eq DateTime.new(2026, 8, 14, 13, 5)
    # Episode add to history button state is updated
    expect(page).to have_css "button[data-controller='history-button'][data-record-type='Episode'][data-record-id='#{episode.id}'][data-status='consumed']"
    # Unreleased episode does not have its state updated
    expect(page).to have_css "button[data-controller='history-button'][data-record-type='Episode'][data-record-id='#{unreleased_episode.id}'][data-status='not_consumed'][disabled]"
    remove_from_history
    # Episode add to history button state is updated, now unconsumed
    expect(page).to have_css "button[data-controller='history-button'][data-record-type='Episode'][data-record-id='#{episode.id}'][data-status='not_consumed']"
    # Unreleased episode does not have its state updated
    expect(page).to have_css "button[data-controller='history-button'][data-record-type='Episode'][data-record-id='#{unreleased_episode.id}'][data-status='not_consumed'][disabled]"

    # Choosing unknown
    open_add_to_history_dialog
    expect(page).to have_css "dialog[data-controller='history-dialog']"
    click_button "Unknown"
    expect(page).to have_css "button[data-option='unknown'][data-active='true']"
    click_button "Confirm"
    # Dialog is now hidden
    expect(page).not_to have_css "dialog[data-controller='history-dialog']"
    # Add to history button state is updated
    expect(page).to have_css "button[data-controller='history-button'][data-record-type='Season'][data-record-id='#{@season.id}'][data-status='consumed']"
    expect(@user.history_items.count).to eq 1
    expect(@user.history_items.first.item).to eq episode
    expect(@user.history_items.first.consumed_at).to be_nil
    # Episode add to history button state is updated
    expect(page).to have_css "button[data-controller='history-button'][data-record-type='Episode'][data-record-id='#{episode.id}'][data-status='consumed']"
    # Unreleased episode does not have its state updated
    expect(page).to have_css "button[data-controller='history-button'][data-record-type='Episode'][data-record-id='#{unreleased_episode.id}'][data-status='not_consumed'][disabled]"
    remove_from_history
    # Episode add to history button state is updated, now unconsumed
    expect(page).to have_css "button[data-controller='history-button'][data-record-type='Episode'][data-record-id='#{episode.id}'][data-status='not_consumed']"
    # Unreleased episode does not have its state updated
    expect(page).to have_css "button[data-controller='history-button'][data-record-type='Episode'][data-record-id='#{unreleased_episode.id}'][data-status='not_consumed'][disabled]"

    # Clicking cancel closes the dialog
    open_add_to_history_dialog
    expect(page).to have_css "dialog[data-controller='history-dialog']"
    click_button "Cancel"
    expect(page).not_to have_css "dialog[data-controller='history-dialog']"
    # Does not add any history items
    expect(@user.history_items.count).to eq 0
  end

  scenario "add to and removing from history from the show page" do
    specials = @season.show.ordered_seasons.first
    episode = FactoryBot.create(:episode, season: @season, number: 1, original_air_date: Date.today)
    FactoryBot.create(:episode, season: specials, number: 1, original_air_date: Date.today)
    season2 = FactoryBot.create(:season, show: @season.show, number: 2)
    season2_episode = FactoryBot.create(:episode, season: season2, number: 1, original_air_date: Date.today)
    season3 = FactoryBot.create(:season, show: @season.show, number: 3)

    sign_in @user

    visit show_path(@season.show)
    expect(page).to have_content @season.show.translated_title

    # Show is not consumed at all
    expect(page).to have_css "button[data-controller='history-button'][data-record-type='Show'][data-record-id='#{@season.show.id}'][data-status='not_consumed']"

    # Season 3 has not been released, so its add to history button is disabled
    expect(page).to have_css "button[data-controller='history-button'][data-record-type='Season'][data-record-id='#{season3.id}'][disabled]"

    # Adding season 1 to history
    open_add_to_history_dialog
    click_button "Confirm"
    # Dialog is now hidden
    expect(page).not_to have_css "dialog[data-controller='history-dialog']"
    # Add to history button state is updated
    expect(page).to have_css "button[data-controller='history-button'][data-record-type='Season'][data-record-id='#{@season.id}'][data-status='consumed']"
    expect(@user.history_items.count).to eq @season.episodes.count
    expect(@user.history_items.first.item).to eq episode
    expect(@user.history_items.first.consumed_at).to eq Time.current
    # The show is now partially consumed
    expect(page).to have_css "button[data-controller='history-button'][data-record-type='Show'][data-record-id='#{@season.show.id}'][data-status='partially_consumed']"

    # Adding season 2 to history
    open_add_to_history_dialog(season2)
    click_button "Confirm"
    # Dialog is now hidden
    expect(page).not_to have_css "dialog[data-controller='history-dialog']"
    # Add to history button state is updated
    expect(page).to have_css "button[data-controller='history-button'][data-record-type='Season'][data-record-id='#{season2.id}'][data-status='consumed']"
    expect(@user.history_items.count).to eq @season.episodes.count + season2.episodes.count
    expect(@user.history_items.second.item).to eq season2_episode
    expect(@user.history_items.first.consumed_at).to eq Time.current
    # The show is now fully consumed as season 3 is not yet released and specials don't count
    expect(page).to have_css "button[data-controller='history-button'][data-record-type='Show'][data-record-id='#{@season.show.id}'][data-status='consumed']"

    # Removing season 1 from history
    remove_from_history(expected_history_count: 1) # Season 2 is still consumed, history count is 1
    # Show is now partially consumed as only season 2 is consumed
    expect(page).to have_css "button[data-controller='history-button'][data-record-type='Show'][data-record-id='#{@season.show.id}'][data-status='partially_consumed']"

    # Removing season 2 from history
    remove_from_history(season2)
    # Show is now not consumed as no episodes are consumed
    expect(page).to have_css "button[data-controller='history-button'][data-record-type='Show'][data-record-id='#{@season.show.id}'][data-status='not_consumed']"
  end

  scenario "adding to and removing from stacks" do
    stack1 = FactoryBot.create(:stack, user: @user, name: "Amazing Stack")
    stack2 = FactoryBot.create(:stack, user: @user, name: "Great Stack")
    episode = FactoryBot.create(:episode, season: @season)

    # Not signed in, so actions are not available
    expect(page).not_to have_css "button[title='More options']"

    sign_in @user
    visit show_season_path(@season, show_id: @season.show)
    expect(page).to have_content "Season #{@season.number}"

    # Now signed in, actions are available
    expect(page).to have_css "button[title='More options']"

    # Dialog is not shown
    expect(page).not_to have_css "dialog[data-controller='stack-dialog']"

    click_button "Season_#{@season.id}_more_options"
    click_button "Add to stack"

    # Dialog is now shown
    expect(page).to have_css "dialog[data-controller='stack-dialog']"

    # Adding to 'Amazing Stack'
    click_button "Amazing Stack"
    expect(page).to have_css "button[data-stack-id='#{stack1.id}'][data-active='true']"
    expect(StackItem.count).to eq 1

    # It does not affect actions for episodes
    click_button "Close"
    click_button "Episode_#{episode.id}_more_options"
    click_button "Add to stack"
    expect(page).to have_css "button[data-stack-id='#{stack1.id}'][data-active='false']"
    click_button "Close"
    expect(page).not_to have_css "dialog[data-controller='stack-dialog']"

    # Adding to 'Great Stack'
    click_button "Season_#{@season.id}_more_options"
    expect(page).to have_css "div#actions-more-options"
    click_button "Add to stack"
    click_button "Great Stack"
    expect(page).to have_css "button[data-stack-id='#{stack2.id}'][data-active='true']"
    expect(StackItem.count).to eq 2

    # Close the dialog
    click_button "Close"

    # Open the dialog again
    click_button "Season_#{@season.id}_more_options"
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
    click_button "Season_#{@season.id}_more_options"
    click_button "Add to stack"

    # New stack is still there, that is active
    expect(page).to have_css "button[data-stack-id='#{new_stack.id}'][data-active='true']"

    # Remove from 'Bad Stack'
    click_button "Bad Stack"
    expect(page).to have_css "button[data-stack-id='#{new_stack.id}'][data-active='false']"
    expect(StackItem.count).to eq 0

    click_button "Close"
    click_button "Season_#{@season.id}_more_options"
    # Counts are updated
    expect(page).to have_css "small[data-stack-button-target='stackCount']", text: "0", visible: false
  end
end
