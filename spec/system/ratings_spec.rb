require "rails_helper"

RSpec.feature "Profile ratings", type: :system, js: true do
  let(:user) { FactoryBot.create(:user, :confirmed) }

  def open_rating(rating)
    button = find("#rating_#{rating.id} button[data-controller=rating-button]")
    scroll_to button, align: :bottom
    button.click
  end

  scenario "editing and removing a filtered rating keeps the card, month and dialog in place" do
    movie = FactoryBot.create(:movie, :with_release_date, translated_title: "Quiet Hours")
    rating = FactoryBot.create(:rating, user:, item: movie, updated_at: Time.zone.local(2026, 10, 20))
    sign_in user
    visit user_ratings_path(user, score: 8)
    expect(page).to have_css("#rating_items h3", text: "October 2026")
    open_rating(rating)
    within("dialog[open]") do
      find("button[aria-label='Rate 9 out of 10']").click
      expect(page).to have_css("button[data-score='9'][aria-pressed=true]")
      click_button "Close"
    end
    expect(page).to have_css("#rating_#{rating.id} button[data-rating-button-score-value='9']")
    expect(page).to have_css("#rating_items h3", text: "October 2026")
    expect(page).to have_checked_field("score_8", visible: :all)
    open_rating(rating)
    within("dialog[open]") do
      find("button[aria-label='Remove your 9/10 rating']").click
      expect(page).to have_text("Unrated")
      click_button "Close"
    end
    expect(page).to have_css("#rating_#{rating.id}")
    open_rating(rating)
    within("dialog[open]") { expect(page).to have_text("Unrated") }
    expect(user.ratings.exists?(item: movie)).to be(false)
  end

  scenario "toggling month headings and changing sorting and filters" do
    movie = FactoryBot.create(:movie, :with_release_date)
    show = FactoryBot.create(:show, :with_premiere_date)
    FactoryBot.create(:rating, user:, item: movie, score: 9, updated_at: Time.zone.local(2026, 11, 20))
    FactoryBot.create(:rating, user:, item: show, score: 7, updated_at: Time.zone.local(2026, 10, 20))
    visit user_ratings_path(user)
    expect(page).to have_css("#rating_items h3", count: 2)
    click_button "Hide dates"
    expect(page).to have_no_css("#rating_items h3")
    expect(page).to have_css("#rating_items article", count: 2)
    click_button "Show dates"
    expect(page).to have_css("#rating_items h3", count: 2)
    slim_select "Highest rated", from: "ratings-sort"
    expect(page).to have_no_button("Hide dates")
    expect(page).to have_no_css("#rating_items h3")
    slim_select "Recently rated", from: "ratings-sort"
    expect(page).to have_css("#rating_items h3", count: 2)
    slim_select "Oldest ratings", from: "ratings-sort"
    expect(page).to have_css("#rating_items h3:first-child", text: "October 2026")
    expect(page).to have_button("Hide dates")
    find("label.groupedButtons-item", text: "Movies", exact_text: true).click
    expect(page).to have_css("#rating_items article", count: 1)
    choose "score_9", allow_label_click: true
    expect(page).to have_text("No ratings match these filters.")
    choose "score_", allow_label_click: true
    expect(page).to have_css("#rating_items article", count: 1)
  end

  scenario "editing after loading more preserves all cards and their score order" do
    stub_const("Users::RatingsController::PER_PAGE", 6)
    high = FactoryBot.create(:rating, user:, score: 10)
    lower = FactoryBot.create_list(:rating, 12, user:, score: 4)
    sign_in user
    visit user_ratings_path(user, sort: "highest")
    lower.reverse.each_slice(6) do |batch|
      scroll_to find("#rating_items"), align: :bottom
      expect(page).to have_css("#rating_#{batch.last.id}")
    end
    expect(page).to have_css("#rating_items article", count: 13)
    open_rating(high)
    within("dialog[open]") do
      find("button[aria-label='Rate 1 out of 10']").click
      expect(page).to have_css("button[data-score='1'][aria-pressed=true]")
      click_button "Close"
    end
    expect(page.all("#rating_items article").map { it[:id] }).to eq([high, *lower.reverse].map { "rating_#{it.id}" })
    visit user_ratings_path(user, sort: "highest")
    expect(page).to have_css("#rating_#{lower.last.id}")
    expect(page).to have_no_css("#rating_#{high.id}")
  end

  scenario "Back and Forward restore sorting, filters and dates after toggling dates" do
    FactoryBot.create(:rating, user:, score: 9)
    FactoryBot.create(:rating, user:, score: 7)
    visit user_ratings_path(user, score: 9)
    click_button "Hide dates"
    slim_select "Highest rated", from: "ratings-sort"
    expect(page).to have_current_path(/sort=highest/)
    expect(page).to have_css("#ratings_content[complete]:not([busy])")
    choose "score_", allow_label_click: true
    expect(page).to have_css("#rating_items article", count: 2)
    expect(page).to have_css("#ratings_content[complete]:not([busy])")

    page.go_back
    expect(page).to have_checked_field("score_9", visible: :all)
    expect(page).to have_css("#rating_items article", count: 1)
    page.go_back
    expect(page).to have_select("sort", selected: "Recently rated", visible: :all)
    expect(page).to have_button("Hide dates")
    expect(page).to have_css("#rating_items[data-show-dates=false]")

    page.go_forward
    expect(page).to have_select("sort", selected: "Highest rated", visible: :all)
    expect(page).to have_no_button("Hide dates")
    expect(page).to have_checked_field("score_9", visible: :all)
    page.go_forward
    expect(page).to have_checked_field("score_", visible: :all)
    expect(page).to have_css("#rating_items article", count: 2)
  end

  scenario "an edited card appearing in a later month leaves no empty heading" do
    stub_const("Users::RatingsController::PER_PAGE", 6)
    oldest = FactoryBot.create(:rating, user:, updated_at: 2.months.ago)
    others = FactoryBot.create_list(:rating, 12, user:, updated_at: 1.month.ago)
    sign_in user
    page.current_window.resize_to(1920, 600)
    visit user_ratings_path(user, sort: "oldest")
    expect(page).to have_css("#rating_items article", count: 6)
    open_rating(oldest)
    within("dialog[open]") do
      find("button[aria-label='Rate 9 out of 10']").click
      expect(page).to have_css("button[data-score='9'][aria-pressed=true]")
      click_button "Close"
    end
    [others[10], others.last].each do |rating|
      scroll_to find("#rating_items"), align: :bottom
      expect(page).to have_css("#rating_#{rating.id}")
    end
    expect(page).to have_no_css("#load_more_ratings", visible: :all)
    expect(page).to have_css("#rating_items article", count: 13)
    expect(page.all("#rating_items h3").map(&:text)).to eq([2.months.ago, 1.month.ago].map { it.strftime("%B %Y") })
  end

  scenario "removing a saved rating after its release date becomes unknown" do
    rating = FactoryBot.create(:rating, user:)
    rating.item.update_columns(release_date: nil)
    sign_in user
    visit user_ratings_path(user)
    open_rating(rating)
    within("dialog[open]") do
      expect(page).to have_css("button[data-score='9'][disabled]")
      find("button[aria-label='Remove your 8/10 rating']").click
      expect(page).to have_text("Unrated")
      click_button "Close"
    end
    expect(page).to have_css("#rating_#{rating.id} button[disabled]")
    expect(Rating.exists?(rating.id)).to be(false)
  end

  scenario "a removed and re-rated card appearing in a later batch is not duplicated or moved" do
    stub_const("Users::RatingsController::PER_PAGE", 6)
    high = FactoryBot.create(:rating, user:, score: 10)
    middle = FactoryBot.create_list(:rating, 12, user:, score: 8)
    low = FactoryBot.create(:rating, user:, score: 2)
    sign_in user
    visit user_ratings_path(user, sort: "highest")
    open_rating(high)
    within("dialog[open]") do
      find("button[aria-label='Rate 3 out of 10']").click
      expect(page).to have_css("button[data-score='3'][aria-pressed=true]")
      find("button[aria-label='Remove your 3/10 rating']").click
      expect(page).to have_text("Unrated")
      find("button[aria-label='Rate 3 out of 10']").click
      expect(page).to have_css("button[data-score='3'][aria-pressed=true]")
      click_button "Close"
    end
    [middle[1], middle.first, low].each do |rating|
      scroll_to find("#rating_items"), align: :bottom
      expect(page).to have_css("#rating_#{rating.id}")
    end
    expect(page.all("#rating_items article").map { it[:id] }).to eq([high, *middle.reverse, low].map { "rating_#{it.id}" })
    expect(page).to have_css("#rating_#{high.id} button[data-rating-button-score-value='3']")
  end
end
