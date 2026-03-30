# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Markdown Rendering", type: :system, js: true do
  before do
    markdown = <<~MARKDOWN
      <div align="center" class="bogus">Div centered</div>
      <p align="center" class="bogus">P centered</p>
      <img align="center" onerror="alert('error')" src="https://github.com/crxssed7.png"/>
      <center>Hello</center>
      <picture><source media="media" height="24px" onerror="alert('error')"></picture>
      <script>console.error('error')</script>
    MARKDOWN
    @user = FactoryBot.create(:user, :confirmed, biography: markdown)
  end

  scenario "Rendering markdown" do
    visit user_path(@user)
    expect(page).to have_css "div.rendered-markdown"
    within("div.rendered-markdown") do
      # Unsafe attributes are stripped, safe ones are kept
      expect(page).not_to have_css("[class='bogus']")
      expect(page).not_to have_css("[onerror]")
      expect(page).to have_css("div[align='center']")
      expect(page).to have_css("p[align='center']")
      expect(page).to have_css("img[align='center'][src='https://github.com/crxssed7.png']")
      expect(page).to have_css("picture", visible: false)
      expect(page).to have_css("source[media='media']", visible: false)

      # Script tags are removed entirely
      expect(page).not_to have_css("script", visible: false)

      # Safe/expected content is rendered
      expect(page).to have_text("Hello")
      expect(page).to have_text("Div centered")
      expect(page).to have_text("P centered")

      # Ensure allowed structure still exists
      expect(page).to have_css("center", text: "Hello")
    end
  end
end
