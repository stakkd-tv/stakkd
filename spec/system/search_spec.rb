# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Search results", type: :system, js: true do
  let(:query) { "test" }

  before do
    stub_const("ApplicationController::GLOBAL_PER_PAGE", 1)
    @movie1 = FactoryBot.create(:movie, translated_title: "Test Movie 1")
    @movie2 = FactoryBot.create(:movie, translated_title: "Test Movie 2")
    @show1 = FactoryBot.create(:show, translated_title: "Test Show 1")

    response = {
      "results" => [
        {"hits" => [{"document" => {"id" => @movie1.id}}], "found" => 2},
        {"hits" => [{"document" => {"id" => @show1.id}}], "found" => 1}
      ]
    }

    expect(Typesense.client.multi_search).to receive(:perform).and_return(response)
    # Load more triggers a search against Movie
    expect(Movie).to receive(:search).with(
      query,
      "translated_title,original_title,alternative_names",
      {page: 2, per_page: 1}
    ).and_return(Movie.where(id: @movie2.id).paginate(page: 1, per_page: 1))

    user = FactoryBot.create(:user, :confirmed)
    sign_in(user)
  end

  scenario "Searching for records", :ignore_console_errors do
    visit root_path
    find("input.nav-search").send_keys(query, :enter)
    expect(page).to have_content "Search - #{query}"

    expect(page).to have_css "button[data-sidetab-active='true']", text: "Movies (2)"
    expect(page).to have_css "button[data-sidetab-active='false']", text: "Shows (1)"
    expect(page).to have_content "Test Movie 1"
    expect(page).to have_content "Test Movie 2" # Load more has been triggered
    expect(page).not_to have_content "Test Show 1"

    click_on "Shows (1)"
    expect(page).to have_css "button[data-sidetab-active='true']", text: "Shows (1)"
    expect(page).to have_css "button[data-sidetab-active='false']", text: "Movies (2)"
    expect(page).not_to have_content "Test Movie 1"
    expect(page).not_to have_content "Test Movie 2"
    expect(page).to have_content "Test Show 1"
  end
end
