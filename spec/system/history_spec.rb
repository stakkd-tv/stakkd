# frozen_string_literal: true

require "rails_helper"

RSpec.feature "History", type: :system, js: true do
  include ActiveSupport::Testing::TimeHelpers

  before do
    travel_to Time.new(2026, 11, 2, 10)
  end

  def expect_history_items(*titles)
    expect(page).to have_css "#history_items p.text-md.font-domine", count: titles.size
    titles.each.with_index(1) do |title, position|
      expect(page).to have_css "#history_items > a:nth-child(#{position} of a) > p.text-md.font-domine", exact_text: title
    end
  end

  def toggle(media_type)
    page.find("label.groupedButtons-item", text: media_type).click
  end

  scenario "filtering history" do
    user = FactoryBot.create(:user, username: "bob")
    movie = FactoryBot.create(:movie, translated_title: "Amazing movie")
    FactoryBot.create(:history_item, user:, item: movie, consumed_at: 4.days.ago)

    show1 = FactoryBot.create(:show, :with_premiere_date, translated_title: "Amazing show")
    episode1 = show1.non_special_episodes.first
    FactoryBot.create(:history_item, user:, item: episode1, consumed_at: 3.days.ago.beginning_of_day)

    show2 = FactoryBot.create(:show, :with_premiere_date, translated_title: "Bad show")
    episode2 = show2.non_special_episodes.first
    FactoryBot.create(:history_item, user:, item: episode2, consumed_at: 3.days.ago.end_of_day)

    show3 = FactoryBot.create(:show, :with_premiere_date, translated_title: "Meh show")
    episode3 = show3.non_special_episodes.first
    FactoryBot.create(:history_item, user:, item: episode3, consumed_at: 2.day.ago.end_of_day)

    visit user_history_index_path(user)
    expect(page).to have_content "bob's history"

    expect_history_items "Meh show", "Bad show", "Amazing show", "Amazing movie"

    toggle "Movies"
    expect_history_items "Meh show", "Bad show", "Amazing show"
    expect(page).to have_current_path("/users/bob/history?hidden_media_types%5B%5D=Movie&hide_dates=false")

    toggle "Movies"
    expect_history_items "Meh show", "Bad show", "Amazing show", "Amazing movie"
    toggle "Episodes"
    expect_history_items "Amazing movie"
    expect(page).to have_current_path("/users/bob/history?hidden_media_types%5B%5D=Episode&hide_dates=false")

    toggle "Episodes"
    expect_history_items "Meh show", "Bad show", "Amazing show", "Amazing movie"
    expect(page).to have_current_path("/users/bob/history?hide_dates=false")

    # Renders dates
    expect(page).to have_css "h3.font-fugaz", count: 3
    expect(page).to have_css "h3.font-fugaz", text: "October 29, 2026", count: 1
    expect(page).to have_css "h3.font-fugaz", text: "October 30, 2026", count: 1
    expect(page).to have_css "h3.font-fugaz", text: "October 31, 2026", count: 1

    click_button "Hide date"
    expect(page).to have_css "h3.font-fugaz", text: "October 29, 2026", count: 0
    expect(page).to have_css "h3.font-fugaz", text: "October 30, 2026", count: 0
    expect(page).to have_css "h3.font-fugaz", text: "October 31, 2026", count: 0
    expect(page).to have_current_path("/users/bob/history?hide_dates=true")

    click_button "Show date"
    expect(page).to have_css "h3.font-fugaz", count: 3
    expect(page).to have_css "h3.font-fugaz", text: "October 29, 2026", count: 1
    expect(page).to have_css "h3.font-fugaz", text: "October 30, 2026", count: 1
    expect(page).to have_css "h3.font-fugaz", text: "October 31, 2026", count: 1
    expect(page).to have_current_path("/users/bob/history")

    # Loading more does not duplicate any dates
    stub_const("Users::HistoryController::PER_PAGE", 2)
    visit user_history_index_path(user)
    expect(page).to have_content "bob's history"
    expect_history_items "Meh show", "Bad show"
    page.execute_script("window.scrollTo(0, document.body.scrollHeight)")
    expect_history_items "Meh show", "Bad show", "Amazing show", "Amazing movie"
    expect(page).to have_css "h3.font-fugaz", count: 3
    expect(page).to have_css "h3.font-fugaz", text: "October 29, 2026", count: 1
    expect(page).to have_css "h3.font-fugaz", text: "October 30, 2026", count: 1
    expect(page).to have_css "h3.font-fugaz", text: "October 31, 2026", count: 1
  end
end
