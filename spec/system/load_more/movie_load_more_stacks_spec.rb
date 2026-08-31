# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Movie load more stacks", type: :system, js: true do
  scenario "Loading more movie stacks" do
    user = FactoryBot.create(:user, :confirmed)
    sign_in user

    movie = FactoryBot.create(:movie)
    7.times do |i|
      stack = FactoryBot.create(:stack, name: "Stack ##{i + 1}", user:)
      FactoryBot.create(:stack_item, item: movie, stack:)
    end
    # Make the first stack private
    Stack.first.update(private: true)
    # Private stack for another user
    private_stack = FactoryBot.create(:stack, private: true, name: "Private Stack")
    FactoryBot.create(:stack_item, item: movie, stack: private_stack)
    # Stack that is not marked as private but the user is
    private_user = FactoryBot.create(:user, private: true)
    private_user_stack = FactoryBot.create(:stack, name: "Private User Stack", user: private_user)
    FactoryBot.create(:stack_item, item: movie, stack: private_user_stack)

    visit movie_path(movie)

    expect(page).to have_content("Stack #7")
    expect(page).to have_content("Stack #6")
    expect(page).to have_content("Stack #5")
    expect(page).not_to have_content("Stack #4")
    expect(page).not_to have_content("Stack #3")
    expect(page).not_to have_content("Stack #2")
    expect(page).not_to have_content("Only you can see this stack")
    expect(page).not_to have_content("Private Stack")
    expect(page).not_to have_content("Private User Stack")
    expect(page).to have_css "turbo-frame#load_more_top_stacks", text: "Load more stacks"
    click_link "Load more stacks"
    expect(page).to have_content("Stack #4")
    expect(page).to have_content("Stack #3")
    expect(page).to have_content("Stack #2")
    expect(page).not_to have_content("Stack #1")
    expect(page).not_to have_content("Only you can see this stack")
    expect(page).not_to have_content("Private Stack")
    expect(page).not_to have_content("Private User Stack")
    click_link "Load more stacks"
    expect(page).to have_content("Stack #1")
    expect(page).to have_content("Only you can see this stack")
    expect(page).not_to have_content("Private Stack")
    expect(page).not_to have_content("Private User Stack")
    expect(page).to have_css "turbo-frame#load_more_top_stacks", count: 0
  end
end
