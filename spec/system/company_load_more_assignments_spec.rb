# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Company load more assignments", type: :system, js: true do
  scenario "Loading more company assignments" do
    stub_const("CompaniesController::COMPANY_ASSIGNMENTS_PER_PAGE", 1)
    company = FactoryBot.create(:company)
    2.times do
      FactoryBot.create(:company_assignment, company:, record: FactoryBot.build(:movie, translated_title: "Cool Movie Name"))
    end

    visit company_path(company)

    expect(page).to have_content("Cool Movie Name", count: 1)
    expect(page).to have_css "a", text: "Load More"
    click_link "Load More"
    expect(page).to have_content("Cool Movie Name", count: 2)
    expect(page).not_to have_css "a", text: "Load More"
  end
end
