require "rails_helper"

RSpec.feature "Ratings load more", type: :system, js: true do
  scenario "loading more preserves filters and does not duplicate month headings" do
    stub_const("Users::RatingsController::PER_PAGE", 6)
    user = FactoryBot.create(:user)
    november = FactoryBot.create_list(:rating, 12, user:, updated_at: Time.zone.local(2026, 11, 20))
    october = FactoryBot.create(:rating, user:, updated_at: Time.zone.local(2026, 10, 20))
    visit user_ratings_path(user, score: 8, hidden_media_types: %w[Show Season Episode])
    [november.first, october].each do |rating|
      scroll_to find("#rating_items"), align: :bottom
      expect(page).to have_css("#rating_#{rating.id}")
    end
    expect(page).to have_css("#rating_items article", count: 13)
    expect(page).to have_css("#rating_items h3", text: "November 2026", count: 1)
    expect(page).to have_css("#rating_items h3", text: "October 2026", count: 1)
    expect(page).to have_checked_field("score_8", visible: :all)
    expect(page).to have_no_css("#load_more_ratings", visible: :all)
  end

  scenario "a batch of duplicate cards does not consume the next visible month's heading" do
    stub_const("Users::RatingsController::PER_PAGE", 6)
    user = FactoryBot.create(:user)
    oldest = FactoryBot.create_list(:rating, 6, user:, updated_at: 2.months.ago)
    middle = FactoryBot.create_list(:rating, 12, user:, updated_at: 1.month.ago)
    newest = FactoryBot.create(:rating, user:, updated_at: Time.current.end_of_month)
    page.current_window.resize_to(1920, 400)
    visit user_ratings_path(user, sort: "oldest")
    expect(page).to have_css("#rating_items article", count: 6)

    # Simulate edits in another tab: these six cards now fill an entire later batch.
    oldest.each { it.update!(score: 9) }
    [middle[5], middle.last, newest].each do |rating|
      scroll_to find("#rating_items"), align: :bottom
      expect(page).to have_css("#rating_#{rating.id}")
    end
    expect(page).to have_no_css("#load_more_ratings", visible: :all)
    expect(page).to have_css("#rating_items article", count: 19)
    expect(page.all("#rating_items h3").map(&:text)).to eq([2.months.ago, 1.month.ago, Time.current].map { it.strftime("%B %Y") })
    expect(page).to have_css("[data-rating-month='#{Time.current.to_date.beginning_of_month.iso8601}'] + #rating_#{newest.id}")
  end
end
