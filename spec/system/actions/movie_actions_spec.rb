# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Movie actions", type: :system, js: true do
  include ActiveSupport::Testing::TimeHelpers

  before do
    travel_to Date.new(2026, 8, 13)
    @user = FactoryBot.create(:user, :confirmed, email_address: "test@example.com", password: "top-secret")
    @movie = FactoryBot.create(:movie)
  end

  def remove_from_history
    open_add_to_history_dialog
    expect(page).to have_css "dialog[data-controller='history-dialog']"
    click_button "Remove from history"
    expect(page).not_to have_css "dialog[data-controller='history-dialog']"
    expect(page).to have_css "button[data-controller='history-button'][data-record-type='Movie'][data-record-id='#{@movie.id}'][data-status='not_consumed']"
    expect(@user.history_items.count).to eq 0
  end

  def open_add_to_history_dialog
    find("button[title='Add to history'][data-record-type='Movie'][data-record-id='#{@movie.id}']").click
  end

  scenario "adding to and removing from history" do
    visit movie_path(@movie)
    expect(page).to have_content @movie.translated_title

    # Not signed in, so add to history button is not on the page
    expect(page).not_to have_css "button[data-controller='history-button'][data-record-type='Movie'][data-record-id='#{@movie.id}']"

    sign_in @user
    visit movie_path(@movie)
    expect(page).to have_content @movie.translated_title

    # Now signed in, add to history button is on the page, not consumed state
    expect(page).to have_css "button[data-controller='history-button'][data-record-type='Movie'][data-record-id='#{@movie.id}'][data-status='not_consumed']"

    # Movie has not been released, add to history is disabled
    expect(page).to have_css "button[data-controller='history-button'][disabled]"

    # Movie is now released
    cert = FactoryBot.create(:certification, country: @movie.country)
    FactoryBot.create(:release, movie: @movie, certification: cert, type: Release::THEATRICAL, date: Date.today)
    page.refresh

    # History dialog is not shown
    expect(page).not_to have_css "dialog[data-controller='history-dialog']"

    open_add_to_history_dialog

    # History dialog is shown with a form for adding to history
    expect(page).to have_css "dialog[data-controller='history-dialog']"
    within "dialog[data-controller='history-dialog']" do
      expect(page).to have_css "form[action='#{add_to_history_movie_path(@movie)}']"
    end

    # Choosing now option
    click_button "Now"
    expect(page).to have_css "button[data-option='now'][data-active='true']"
    click_button "Confirm"
    # Dialog is now hidden
    expect(page).not_to have_css "dialog[data-controller='history-dialog']"
    # Add to history button state is updated
    expect(page).to have_css "button[data-controller='history-button'][data-record-type='Movie'][data-record-id='#{@movie.id}'][data-status='consumed']"
    expect(@user.history_items.count).to eq 1
    expect(@user.history_items.first.item).to eq @movie
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
    expect(page).to have_css "button[data-controller='history-button'][data-record-type='Movie'][data-record-id='#{@movie.id}'][data-status='consumed']"
    expect(@user.history_items.count).to eq 1
    expect(@user.history_items.first.item).to eq @movie
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
    page.find("span.flatpickr-day", text: "14").click
    page.find("input.flatpickr-hour").fill_in(with: "13")
    page.find("input.flatpickr-minute").fill_in(with: "05")
    click_button "Confirm"
    # Dialog is now hidden
    expect(page).not_to have_css "dialog[data-controller='history-dialog']"
    # Add to history button state is updated
    expect(page).to have_css "button[data-controller='history-button'][data-record-type='Movie'][data-record-id='#{@movie.id}'][data-status='consumed']"
    expect(@user.history_items.count).to eq 1
    expect(@user.history_items.first.item).to eq @movie
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
    expect(page).to have_css "button[data-controller='history-button'][data-record-type='Movie'][data-record-id='#{@movie.id}'][data-status='consumed']"
    expect(@user.history_items.count).to eq 1
    expect(@user.history_items.first.item).to eq @movie
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
end
