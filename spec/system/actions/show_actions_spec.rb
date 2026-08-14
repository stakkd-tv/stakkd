# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Show actions", type: :system, js: true do
  include ActiveSupport::Testing::TimeHelpers

  before do
    travel_to Date.new(2026, 8, 13)
    @user = FactoryBot.create(:user, :confirmed, email_address: "test@example.com", password: "top-secret")
    @show = FactoryBot.create(:show)
  end

  def remove_from_history
    open_add_to_history_dialog
    expect(page).to have_css "dialog[data-controller='history-dialog']"
    click_button "Clear history"
    expect(page).not_to have_css "dialog[data-controller='history-dialog']"
    expect(page).to have_css "button[data-controller='history-button'][data-record-type='Show'][data-record-id='#{@show.id}'][data-status='not_consumed']"
    expect(@user.history_items.count).to eq 0
  end

  def open_add_to_history_dialog
    find("button[title='Add to history'][data-record-type='Show'][data-record-id='#{@show.id}']").click
  end

  scenario "adding to and removing from history" do
    visit show_path(@show)
    expect(page).to have_content @show.translated_title

    # Not signed in, so add to history button is not on the page
    expect(page).not_to have_css "button[data-controller='history-button'][data-record-type='Show'][data-record-id='#{@show.id}']"

    sign_in @user
    visit show_path(@show)
    expect(page).to have_content @show.translated_title

    # Now signed in, add to history button is on the page, not consumed state
    expect(page).to have_css "button[data-controller='history-button'][data-record-type='Show'][data-record-id='#{@show.id}'][data-status='not_consumed']"

    # Show has not been released, add to history is disabled
    expect(page).to have_css "button[data-controller='history-button'][disabled]"

    # Show is now released
    season = FactoryBot.create(:season, :with_premiere_date, show: @show, number: 1)
    specials = @show.ordered_seasons.first
    # Creating special episodes
    FactoryBot.create(:episode, season: specials, original_air_date: Date.today)
    page.refresh

    # History dialog is not shown
    expect(page).not_to have_css "dialog[data-controller='history-dialog']"

    # Season is not consumed
    expect(page).to have_css "button[data-controller='history-button'][data-record-type='Season'][data-record-id='#{season.id}'][data-status='not_consumed']"
    # Specials are not consumed
    expect(page).to have_css "button[data-controller='history-button'][data-record-type='Season'][data-record-id='#{specials.id}'][data-status='not_consumed']"

    open_add_to_history_dialog

    # History dialog is shown with a form for adding to history
    expect(page).to have_css "dialog[data-controller='history-dialog']"
    within "dialog[data-controller='history-dialog']" do
      expect(page).to have_css "form[action='#{add_to_history_show_path(@show)}']"
    end

    # Choosing now option
    click_button "Now"
    expect(page).to have_css "button[data-option='now'][data-active='true']"
    click_button "Confirm"
    # Dialog is now hidden
    expect(page).not_to have_css "dialog[data-controller='history-dialog']"
    # Add to history button state is updated
    expect(page).to have_css "button[data-controller='history-button'][data-record-type='Show'][data-record-id='#{@show.id}'][data-status='consumed']"
    expect(@user.history_items.count).to eq 1
    expect(@user.history_items.first.item).to eq season.episodes.first
    expect(@user.history_items.first.consumed_at).to eq Time.current
    # Season is now consumed
    expect(page).to have_css "button[data-controller='history-button'][data-record-type='Season'][data-record-id='#{season.id}'][data-status='consumed']"
    # Specials are not consumed as they do not count towards progress
    expect(page).to have_css "button[data-controller='history-button'][data-record-type='Season'][data-record-id='#{specials.id}'][data-status='not_consumed']"
    remove_from_history
    # Season is now unconsumed
    expect(page).to have_css "button[data-controller='history-button'][data-record-type='Season'][data-record-id='#{season.id}'][data-status='not_consumed']"
    # Specials do not have their status updated
    expect(page).to have_css "button[data-controller='history-button'][data-record-type='Season'][data-record-id='#{specials.id}'][data-status='not_consumed']"

    # Choosing release date option
    open_add_to_history_dialog
    expect(page).to have_css "dialog[data-controller='history-dialog']"
    click_button "Release date"
    expect(page).to have_css "button[data-option='release_date'][data-active='true']"
    click_button "Confirm"
    # Dialog is now hidden
    expect(page).not_to have_css "dialog[data-controller='history-dialog']"
    # Add to history button state is updated
    expect(page).to have_css "button[data-controller='history-button'][data-record-type='Show'][data-record-id='#{@show.id}'][data-status='consumed']"
    expect(@user.history_items.count).to eq 1
    expect(@user.history_items.first.item).to eq season.episodes.first
    expect(@user.history_items.first.consumed_at).to eq Date.today.beginning_of_day
    # Season is now consumed
    expect(page).to have_css "button[data-controller='history-button'][data-record-type='Season'][data-record-id='#{season.id}'][data-status='consumed']"
    # Specials are not consumed as they do not count towards progress
    expect(page).to have_css "button[data-controller='history-button'][data-record-type='Season'][data-record-id='#{specials.id}'][data-status='not_consumed']"
    remove_from_history
    # Season is now unconsumed
    expect(page).to have_css "button[data-controller='history-button'][data-record-type='Season'][data-record-id='#{season.id}'][data-status='not_consumed']"
    # Specials do not have their status updated
    expect(page).to have_css "button[data-controller='history-button'][data-record-type='Season'][data-record-id='#{specials.id}'][data-status='not_consumed']"

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
    expect(page).to have_css "button[data-controller='history-button'][data-record-type='Show'][data-record-id='#{@show.id}'][data-status='consumed']"
    expect(@user.history_items.count).to eq 1
    expect(@user.history_items.first.item).to eq season.episodes.first
    expect(@user.history_items.first.consumed_at).to eq DateTime.new(2026, 8, 14, 13, 5)
    # Season is now consumed
    expect(page).to have_css "button[data-controller='history-button'][data-record-type='Season'][data-record-id='#{season.id}'][data-status='consumed']"
    # Specials are not consumed as they do not count towards progress
    expect(page).to have_css "button[data-controller='history-button'][data-record-type='Season'][data-record-id='#{specials.id}'][data-status='not_consumed']"
    remove_from_history
    # Season is now unconsumed
    expect(page).to have_css "button[data-controller='history-button'][data-record-type='Season'][data-record-id='#{season.id}'][data-status='not_consumed']"
    # Specials do not have their status updated
    expect(page).to have_css "button[data-controller='history-button'][data-record-type='Season'][data-record-id='#{specials.id}'][data-status='not_consumed']"

    # Choosing unknown
    open_add_to_history_dialog
    expect(page).to have_css "dialog[data-controller='history-dialog']"
    click_button "Unknown"
    expect(page).to have_css "button[data-option='unknown'][data-active='true']"
    click_button "Confirm"
    # Dialog is now hidden
    expect(page).not_to have_css "dialog[data-controller='history-dialog']"
    # Add to history button state is updated
    expect(page).to have_css "button[data-controller='history-button'][data-record-type='Show'][data-record-id='#{@show.id}'][data-status='consumed']"
    expect(@user.history_items.count).to eq 1
    expect(@user.history_items.first.item).to eq season.episodes.first
    expect(@user.history_items.first.consumed_at).to be_nil
    # Season is now consumed
    expect(page).to have_css "button[data-controller='history-button'][data-record-type='Season'][data-record-id='#{season.id}'][data-status='consumed']"
    # Specials are not consumed as they do not count towards progress
    expect(page).to have_css "button[data-controller='history-button'][data-record-type='Season'][data-record-id='#{specials.id}'][data-status='not_consumed']"
    remove_from_history
    # Season is now unconsumed
    expect(page).to have_css "button[data-controller='history-button'][data-record-type='Season'][data-record-id='#{season.id}'][data-status='not_consumed']"
    # Specials do not have their status updated
    expect(page).to have_css "button[data-controller='history-button'][data-record-type='Season'][data-record-id='#{specials.id}'][data-status='not_consumed']"

    # Clicking cancel closes the dialog
    open_add_to_history_dialog
    expect(page).to have_css "dialog[data-controller='history-dialog']"
    click_button "Cancel"
    expect(page).not_to have_css "dialog[data-controller='history-dialog']"
    # Does not add any history items
    expect(@user.history_items.count).to eq 0

    # Watching specials does not count towards show progress
    find("button[title='Add to history'][data-record-type='Season'][data-record-id='#{specials.id}']").click
    expect(page).to have_css "dialog[data-controller='history-dialog']"
    click_button "Confirm"
    expect(page).not_to have_css "dialog[data-controller='history-dialog']"
    expect(@user.history_items.count).to eq 1
    expect(page).to have_css "button[data-controller='history-button'][data-record-type='Show'][data-record-id='#{@show.id}'][data-status='not_consumed']"
  end
end
