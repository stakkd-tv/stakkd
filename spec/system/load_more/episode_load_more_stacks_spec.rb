# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Episode load more stacks", type: :system, js: true do
  scenario "Loading more episode stacks" do
    user = FactoryBot.create(:user, :confirmed)
    sign_in user

    episode = FactoryBot.create(:episode)
    season = episode.season
    show = season.show
    7.times do |i|
      stack = FactoryBot.create(:stack, name: "Stack ##{i + 1}", user:)
      FactoryBot.create(:stack_item, item: episode, stack:)
    end
    # Make the first stack private
    Stack.first.update(private: true)
    # Private stack for another user
    FactoryBot.create(:stack, private: true, name: "Private Stack")

    visit show_season_episode_path(show, season, episode)

    expect(page).to have_content("Stack #7")
    expect(page).to have_content("Stack #6")
    expect(page).to have_content("Stack #5")
    expect(page).not_to have_content("Only you can see this stack")
    expect(page).not_to have_content("Private Stack")
    expect(page).to have_css "turbo-frame#load_more_top_stacks", text: "Load more stacks"
    click_link "Load more stacks"
    expect(page).to have_content("Stack #4")
    expect(page).to have_content("Stack #3")
    expect(page).to have_content("Stack #2")
    expect(page).not_to have_content("Only you can see this stack")
    expect(page).not_to have_content("Private Stack")
    click_link "Load more stacks"
    expect(page).to have_content("Stack #1")
    expect(page).to have_content("Only you can see this stack")
    expect(page).not_to have_content("Private Stack")
    expect(page).to have_css "turbo-frame#load_more_top_stacks", count: 0
  end
end
