# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Stack controls", type: :system, js: true do
  def ordered_stack_item_titles
    page.all("h5.stack-item").map(&:text)
  end

  scenario "interacting with the stack controls" do
    stack = FactoryBot.create(:stack, name: "Ranking of Kings", sorting_method: "added_at", sorting_direction: "asc")
    movie = FactoryBot.create(:movie, translated_title: "King of the Hill")
    FactoryBot.create(:stack_item, stack:, added_at: 3.seconds.ago, position: 2, item: movie)
    show = FactoryBot.create(:show, translated_title: "The Dark Knight")
    FactoryBot.create(:stack_item, stack:, added_at: 2.seconds.ago, position: 1, item: show)
    visit user_stack_path(stack, user_id: stack.user)

    # Inputs are set to default
    expect(page).to have_content("Ranking of Kings")
    expect(page).to have_css("option[selected][value='added_at']")
    expect(page).to have_css("i[data-direction='asc']")
    expect(ordered_stack_item_titles).to eq(["King of the Hill", "The Dark Knight"])

    # Changing sorting method updates DOM and url
    slim_select "Position", from: "sort"
    sleep 0.5
    expect(ordered_stack_item_titles).to eq(["The Dark Knight", "King of the Hill"])
    expect(page).to have_current_path(user_stack_path(stack, user_id: stack.user, direction: "asc", sort: "position"))

    # Changing direction updates DOM and url
    page.find("i[data-direction='asc']").click
    sleep 0.5
    expect(ordered_stack_item_titles).to eq(["King of the Hill", "The Dark Knight"])
    expect(page).to have_current_path(user_stack_path(stack, user_id: stack.user, direction: "desc", sort: "position"))

    # Changing filters
    # Initial filters are empty
    expect(page).to have_css "div.ss-placeholder", text: "Filters"
    # Select Episodes
    slim_select "Episodes", from: "filters"
    sleep 0.5
    expect(ordered_stack_item_titles).to eq([])
    # Both Episodes and Seasons are selected
    slim_select "Seasons", from: "filters"
    sleep 0.5
    expect(ordered_stack_item_titles).to eq([])
    # Episodes, Seasons and Shows are selected
    slim_select "Shows", from: "filters"
    sleep 0.5
    expect(ordered_stack_item_titles).to eq(["The Dark Knight"])
    # All media types selected
    slim_select "Movies", from: "filters"
    sleep 0.5
    expect(ordered_stack_item_titles).to eq(["King of the Hill", "The Dark Knight"])
    # Remove Shows from filter
    slim_select "Shows", from: "filters"
    sleep 0.5
    expect(ordered_stack_item_titles).to eq(["King of the Hill"])
  end
end
