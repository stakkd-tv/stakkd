# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Settings", type: :system, js: true do
  before do
    @user = FactoryBot.create(:user, :confirmed)
    sign_in(@user)
  end

  scenario "Updating user settings", :ignore_form_failures do
    visit user_settings_path
    expect(page).to have_content("Your Settings")

    attach_file "user_profile_picture", Rails.root.join("spec/support/assets/400x400.png"), make_visible: true
    using_wait_time 5 do
      expect(page).to have_selector("#profile-picture-image[src*='data:image/png']")
    end

    attach_file "user_background", Rails.root.join("spec/support/assets/400x400.png"), make_visible: true
    using_wait_time 5 do
      expect(page).to have_selector("#background-image[src*='data:image/png']")
    end

    bio_editor = page.find(".CodeMirror")
    bio_editor.click
    page.send_keys("**Markdown** is *sooooo* great!")

    private_toggle = page.find("div[data-controller='toggle'][id='private'] div[data-toggle-target='toggleContainer']")
    private_toggle.click

    click_button "Save"
    expect(page).to have_content("Settings updated successfully.")

    @user.reload
    expect(@user.profile_picture).to be_attached
    expect(@user.background).to be_attached
    expect(@user.biography).to eq "**Markdown** is *sooooo* great!"
    expect(@user.private).to be_truthy
  end

  scenario "Adding inline spoilers with the toolbar", :ignore_form_failures do
    visit user_settings_path
    find(".CodeMirror").click
    page.send_keys("First spoiler", [:shift, :home])

    click_button "Spoiler"
    click_button "Spoiler"
    expect(page.evaluate_script("document.querySelector('.CodeMirror').CodeMirror.getValue()")).to eq "First spoiler"

    click_button "Spoiler"

    page.send_keys(:end, " and ")
    click_button "Spoiler"
    page.send_keys("second spoiler", :left)
    expect(page).to have_css('button.spoiler.active[aria-pressed="true"]')

    page.send_keys(:end)
    expect(page).to have_css('button.spoiler[aria-pressed="false"]:not(.active)')

    click_button "Toggle Preview (Ctrl-P)"
    expect(page).to have_css(".rendered-markdown span.spoiler", text: "First spoiler")
    expect(page).to have_css(".rendered-markdown span.spoiler", text: "second spoiler")

    click_button "Save"
    expect(page).to have_content("Settings updated successfully.")
    expect(@user.reload.biography).to eq "||First spoiler|| and ||second spoiler||"

    visit user_path(@user)
    expect(page).to have_css(".rendered-markdown span.spoiler", text: "First spoiler")
    expect(page).to have_css(".rendered-markdown span.spoiler", text: "second spoiler")
  end

  scenario "Ignoring spoiler delimiters inside code" do
    markdown = <<~MARKDOWN.chomp
      `||inline code||`

      ```ruby
      ||fenced code||
      ```

      ||spoiler||
    MARKDOWN
    @user.update!(biography: markdown)
    visit user_settings_path
    editor = find(".CodeMirror")

    [[0, 5], [2, 0], [3, 5]].each do |line, column|
      editor.execute_script("this.CodeMirror.setCursor(arguments[0], arguments[1])", line, column)
      expect(page).to have_css('button.spoiler[aria-disabled="true"][aria-pressed="false"]')
      click_button "Spoiler"
      expect(editor.evaluate_script("this.CodeMirror.getValue()")).to eq markdown
    end

    editor.execute_script("this.CodeMirror.setCursor(6, 5)")
    expect(page).to have_css('button.spoiler.active[aria-disabled="false"][aria-pressed="true"]')
  end

  scenario "Toggling a spoiler after an unmatched delimiter in another paragraph" do
    @user.update!(biography: "||draft\n\n||secret||")
    visit user_settings_path
    editor = find(".CodeMirror")
    editor.execute_script("this.CodeMirror.setCursor(0, 4)")
    expect(page).to have_css('button.spoiler[aria-disabled="true"][aria-pressed="false"]')
    click_button "Spoiler"
    expect(editor.evaluate_script("this.CodeMirror.getValue()")).to eq "||draft\n\n||secret||"

    editor.execute_script("this.CodeMirror.setCursor(2, 5)")
    expect(page).to have_css('button.spoiler[aria-pressed="true"]')
    click_button "Spoiler"
    expect(editor.evaluate_script("this.CodeMirror.getValue()")).to eq "||draft\n\nsecret"
  end

  scenario "Rejecting selections that cross spoilers or paragraph boundaries" do
    markdown = "before ||secret|| after\n\nsecond paragraph"
    @user.update!(biography: markdown)
    visit user_settings_path
    editor = find(".CodeMirror")

    [[0, 0, 0, 23], [0, 18, 2, 16]].each do |from_line, from_column, to_line, to_column|
      editor.execute_script(
        "this.CodeMirror.setSelection({line: arguments[0], ch: arguments[1]}, {line: arguments[2], ch: arguments[3]})",
        from_line, from_column, to_line, to_column
      )
      expect(page).to have_css('button.spoiler[aria-disabled="true"][aria-pressed="false"]')
      click_button "Spoiler"
      expect(editor.evaluate_script("this.CodeMirror.getValue()")).to eq markdown
    end
  end

  scenario "Rejecting selections that include block markers or image alt text" do
    markdown = "# Heading\nBody\n\n- Item\n\n![label](picture.png)"
    @user.update!(biography: markdown)
    visit user_settings_path
    editor = find(".CodeMirror")

    [[0, 0, 0, 0], [0, 0, 1, 4], [3, 0, 3, 6], [5, 2, 5, 7]].each do |from_line, from_column, to_line, to_column|
      editor.execute_script(
        "this.CodeMirror.setSelection({line: arguments[0], ch: arguments[1]}, {line: arguments[2], ch: arguments[3]})",
        from_line, from_column, to_line, to_column
      )
      expect(page).to have_css('button.spoiler[aria-disabled="true"][aria-pressed="false"]')
      click_button "Spoiler"
      expect(editor.evaluate_script("this.CodeMirror.getValue()")).to eq markdown
    end
  end

  scenario "Sanitizing markdown" do
    markdown = <<~MARKDOWN
      ||some spoiler text||
      <div align="center" class="bogus">Div centered</div>
      <p align="center" class="bogus">P centered</p>
      <img align="center" onerror="alert('error')" src="https://github.com/crxssed7.png"/>
      <center>Hello</center>
      <picture><source media="media" height="24px" onerror="alert('error')"></picture>
      <script>console.error('error')</script>
    MARKDOWN
    @user.update(biography: markdown)
    visit user_settings_path
    click_button "Toggle Preview (Ctrl-P)"
    expect(page).to have_css "div.rendered-markdown"
    within("div.rendered-markdown") do
      # Unsafe attributes are stripped, safe ones are kept
      expect(page).not_to have_css("[class='bogus']")
      expect(page).not_to have_css("[onerror]")
      expect(page).to have_css("span.spoiler", text: "some spoiler text")
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
