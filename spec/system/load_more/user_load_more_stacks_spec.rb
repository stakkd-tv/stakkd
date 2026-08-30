# frozen_string_literal: true

require "rails_helper"

RSpec.feature "User load more stacks", type: :system, js: true do
  scenario "User viewing own stacks" do
    user = FactoryBot.create(:user, :confirmed)
    sign_in user

    19.times do |i|
      # Even though they are private, the user can see them
      FactoryBot.create(:stack, name: "Stack ##{i + 1}", user:, private: true)
    end

    visit user_path(user)
    click_link "Stacks"
    expect(page).to have_css("a[href='#{user_stacks_path(user)}'][data-active='true']")

    expect(page).to have_content("Stack #19")
    expect(page).to have_content("Stack #18")
    expect(page).to have_content("Stack #17")
    expect(page).to have_content("Stack #16")
    expect(page).to have_content("Stack #15")
    expect(page).to have_content("Stack #14")
    expect(page).to have_content("Stack #13")
    expect(page).to have_content("Stack #12")
    expect(page).to have_content("Stack #11")
    expect(page).not_to have_content("Stack #10")
    expect(page).not_to have_content("Stack #9")
    expect(page).not_to have_content("Stack #8")
    expect(page).not_to have_content("Stack #7")
    expect(page).not_to have_content("Stack #6")
    expect(page).not_to have_content("Stack #5")
    expect(page).not_to have_content("Stack #4")
    expect(page).not_to have_content("Stack #3")
    expect(page).not_to have_content("Stack #2")
    expect(page).to have_css "turbo-frame#load_more_top_stacks", text: "Load more stacks"
    click_link "Load more stacks"
    expect(page).to have_content("Stack #10")
    expect(page).to have_content("Stack #9")
    expect(page).to have_content("Stack #8")
    expect(page).to have_content("Stack #7")
    expect(page).to have_content("Stack #6")
    expect(page).to have_content("Stack #5")
    expect(page).to have_content("Stack #4")
    expect(page).to have_content("Stack #3")
    expect(page).to have_content("Stack #2")
    click_link "Load more stacks"
    expect(page).to have_content("Stack #1")
    expect(page).to have_css "turbo-frame#load_more_top_stacks", count: 0
  end

  scenario "User viewing another users stacks" do
    user = FactoryBot.create(:user, :confirmed)
    sign_in user

    other_user = FactoryBot.create(:user, :confirmed)
    19.times do |i|
      FactoryBot.create(:stack, name: "Stack ##{i + 1}", user: other_user)
    end
    # A private stack
    FactoryBot.create(:stack, user: other_user, private: true, name: "Private Stack")

    visit user_path(other_user)
    click_link "Stacks"
    expect(page).to have_css("a[href='#{user_stacks_path(other_user)}'][data-active='true']")

    expect(page).not_to have_content("Private Stack")
    expect(page).to have_css "turbo-frame#load_more_top_stacks", text: "Load more stacks"
    click_link "Load more stacks"
    expect(page).to have_css "turbo-frame#load_more_top_stacks", text: "Load more stacks"
    expect(page).not_to have_content("Private Stack")
    click_link "Load more stacks"
    expect(page).to have_css "turbo-frame#load_more_top_stacks", count: 0
    expect(page).not_to have_content("Private Stack")
  end
end
