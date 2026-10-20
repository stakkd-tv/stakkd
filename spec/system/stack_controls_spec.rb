# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Stack controls", type: :system, js: true do
  def ordered_stack_item_titles
    page.all("h5.stack-item").map(&:text)
  end

  def ordered_position_detail
    page.all(".stackItem-position").map(&:text)
  end

  def move(element, to:)
    page.driver.browser.action
      .move_to(element.native)
      .click_and_hold
      .move_to(to.native)
      .release
      .perform
  end

  def expect_reordering_available
    expect(page).not_to have_css "button[data-stack-controls-target='reorderingButton'][disabled]"
    expect(page).to have_css "button[data-stack-controls-target='reorderingButton']"
  end

  def expect_reordering_enabled(drag_handle_count:)
    expect(page).to have_css "i.fa-up-down-left-right[data-enabled='true']"
    expect_reordering_available
    expect(page).to have_css "i.drag-handle", count: drag_handle_count
  end

  def expect_reordering_disabled
    expect(page).to have_css "i.fa-up-down-left-right[data-enabled='false']"
    expect(page).to have_css "button[data-stack-controls-target='reorderingButton'][disabled]"
    expect(page).not_to have_css "i.drag-handle"
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

    # Reordering is not possible, as not signed in as stack creator
    expect(page).not_to have_css "button[data-stack-controls-target='reorderingButton']"

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

  scenario "reordering" do
    stack = FactoryBot.create(:stack, name: "Ranking of Kings", sorting_method: "added_at", sorting_direction: "asc")
    StackItem.acts_as_list_no_update do
      movie = FactoryBot.create(:movie, translated_title: "King of the Hill")
      @stack_item1 = FactoryBot.create(:stack_item, stack:, added_at: 3.seconds.ago, position: 2, item: movie)
      show = FactoryBot.create(:show, translated_title: "The Dark Knight")
      @stack_item2 = FactoryBot.create(:stack_item, stack:, added_at: 2.seconds.ago, position: 1, item: show)
    end
    stack.user.update(confirmed_at: Time.current)
    sign_in(stack.user)
    visit user_stack_path(stack, user_id: stack.user)

    # Reordering is not possible on page load due to default sorting method being added_at
    expect(page).to have_css "button[data-stack-controls-target='reorderingButton'][disabled]"

    stack.update(sorting_method: "position")
    page.refresh

    # Reordering is now possible on page load as default sorting method is now position
    expect_reordering_available

    # Drag handles are not visible by default
    expect(page).not_to have_css "i.drag-handle"

    # Enabling reordering updates the icon and displays drag handles
    click_button "Reorder items"
    expect_reordering_enabled(drag_handle_count: 2)

    # Interacting with sort direction while reordering is enabled disables it
    page.find("i[data-direction='asc']").click
    expect_reordering_disabled
    page.find("i[data-direction='desc']").click
    expect_reordering_available

    # Interacting with sorting method while reordering is enabled disables it
    click_button "Reorder items"
    expect_reordering_enabled(drag_handle_count: 2)
    slim_select "Added at", from: "sort"
    expect_reordering_disabled
    slim_select "Position", from: "sort"
    expect_reordering_available

    # Interacting with filters while reordering is enabled disables it
    click_button "Reorder items"
    expect_reordering_enabled(drag_handle_count: 2)
    slim_select "Shows", from: "filters"
    expect_reordering_disabled
    slim_select "Shows", from: "filters" # Reset filters
    expect_reordering_available
    sleep 0.5

    # Now reorder the second item to be the first
    expect(@stack_item1.reload.position).to eq 2
    expect(@stack_item2.reload.position).to eq 1
    click_button "Reorder items"
    expect_reordering_enabled(drag_handle_count: 2)
    expect(ordered_stack_item_titles).to eq(["The Dark Knight", "King of the Hill"])
    expect(ordered_position_detail).to eq(["1", "2"])
    drag_handle = find_all(".drag-handle").last
    target = find_all(".drag-handle").first
    move drag_handle, to: target
    expect(ordered_stack_item_titles).to eq(["King of the Hill", "The Dark Knight"])
    # It keeps the sorting detail up to date for all items in the stack
    expect(ordered_position_detail).to eq(["1", "2"])
    expect(@stack_item1.reload.position).to eq 1
    expect(@stack_item2.reload.position).to eq 2
  end
end
