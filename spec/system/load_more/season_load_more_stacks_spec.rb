# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Season load more stacks", type: :system, js: true do
  scenario "Loading more season stacks" do
    season = FactoryBot.create(:season)
    show = season.show
    7.times do |i|
      stack = FactoryBot.create(:stack, name: "Stack ##{i + 1}")
      FactoryBot.create(:stack_item, item: season, stack:)
    end

    visit show_season_path(show, season)

    expect(page).to have_content("Stack #7")
    expect(page).to have_content("Stack #6")
    expect(page).to have_content("Stack #5")
    expect(page).to have_css "turbo-frame#load_more_top_stacks", text: "Load more stacks"
    click_link "Load more stacks"
    expect(page).to have_content("Stack #4")
    expect(page).to have_content("Stack #3")
    expect(page).to have_content("Stack #2")
    click_link "Load more stacks"
    expect(page).to have_content("Stack #1")
    expect(page).to have_css "turbo-frame#load_more_top_stacks", count: 0
  end
end
