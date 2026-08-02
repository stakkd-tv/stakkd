# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Franchise form", type: :system, js: true do
  before do
    @movie = FactoryBot.create(:movie, translated_title: "Amazing movie")

    user = FactoryBot.create(:user, :confirmed)
    sign_in(user)
  end

  scenario "Using the franchise form", :ignore_form_failures do
    visit franchises_path
    expect(page).to have_content("Franchises")

    # Errors
    click_link "Add a franchise"
    fill_in "franchise_translated_title", with: " "
    fill_in "franchise_original_title", with: " "
    click_button "Save"
    expect(page).to have_content("Translated title can't be blank")
    expect(page).to have_content("Original title can't be blank")

    # Details
    fill_in "franchise_translated_title", with: "Test title"
    fill_in "franchise_original_title", with: "Original title"
    fill_in "franchise_overview", with: "This is an overview"
    fill_in "franchise_homepage", with: "https://example.com"
    click_button "Save"
    expect(page).to have_content("Franchise was successfully created, you can now add items to it.")
    franchise = Franchise.includes(:franchise_items).last

    # Posters
    click_link "Posters"
    expect(page).to have_css("a[data-active='true']", text: "Posters")
    expect(page).to have_content("Width must be between 300px and 2000px")
    attach_file "upload_input", [Rails.root.join("spec/support/assets/299x449.png"), Rails.root.join("spec/support/assets/300x450.png")]
    using_wait_time 5 do
      expect(page).to have_content("300x450.png uploaded")
      expect(page).to have_content("299x449.png: Width must be between 300px and 2000px, Height must be between 450px and 3000px")
    end
    expect(page).to have_css("img[src*='300x450.png']")
    expect(page).not_to have_css("img[src*='299x449.png']")

    # Backgrounds
    click_link "Backgrounds"
    expect(page).to have_css("a[data-active='true']", text: "Backgrounds")
    expect(page).to have_content("Width must be between 1280px and 3840px")
    attach_file "upload_input", [Rails.root.join("spec/support/assets/1279x719.png"), Rails.root.join("spec/support/assets/1280x720.png")]
    using_wait_time 5 do
      expect(page).to have_content("1280x720.png uploaded")
      expect(page).to have_content("1279x719.png: Width must be between 1280px and 3840px, Height must be between 720px and 2160px")
    end
    expect(page).to have_css("img[src*='1280x720.png']")
    expect(page).not_to have_css("img[src*='1279x719.png']")

    # Logos
    click_link "Logos"
    expect(page).to have_css("a[data-active='true']", text: "Logos")
    expect(page).to have_content("Width must be between 400px and 3000px")
    attach_file "upload_input", [Rails.root.join("spec/support/assets/400x400.png"), Rails.root.join("spec/support/assets/399x399.png")]
    using_wait_time 5 do
      expect(page).to have_content("400x400.png uploaded")
      expect(page).to have_content("399x399.png: Width must be between 400px and 3000px, Height must be between 400px and 3000px")
    end
    expect(page).to have_css("img[src*='400x400.png']")
    expect(page).not_to have_css("img[src*='399x399.png']")

    # Items
    click_link "Items"
    expect(page).to have_css("a[data-active='true']", text: "Items")
    fill_in "record", with: "amazing"
    expect(page).to have_css "li.p-2", text: "Amazing movie"
    find("li.p-2", text: "Amazing movie").click
    expect(page).to have_content("Selected: Amazing movie")
    click_button "Save"
    using_wait_time 5 do
      expect(page).to have_css "div.tabulator-cell", text: "Amazing movie"
      expect(franchise.reload.franchise_items.count).to eq 1
    end
    find("div.tabulator-cell>svg").click # press delete button
    using_wait_time 5 do
      expect(page).not_to have_css "div.tabulator-cell", text: "Amazing movie"
      expect(franchise.reload.franchise_items).to eq []
    end
  end
end
