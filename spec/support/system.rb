Capybara.register_driver :selenium_chrome_headless do |app|
  args = ["--headless=new", "--window-size=1920,1080"]
  options = Selenium::WebDriver::Chrome::Options.new(args:)
  Capybara::Selenium::Driver.new(app, browser: :chrome, options:)
end

Capybara.register_driver :selenium_chrome_headless_mobile do |app|
  args = ["--headless=new", "--window-size=500,1000"]
  options = Selenium::WebDriver::Chrome::Options.new(args:)
  Capybara::Selenium::Driver.new(app, browser: :chrome, options:)
end

def assert_no_console_errors(page, excludes = [])
  errors = page
    .driver
    .browser
    .logs
    .get(:browser)
    .select { it.level == "SEVERE" }
    .reject { |error| excludes.any? { |exclude| error.message.include?(exclude) } }
  if errors.present?
    message = errors.map(&:message).join("\n")
    raise "Failed due to browser console errors: #{message}"
  end
end

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :rack_test
  end

  config.before(:each, type: :system, js: true) do |example|
    example.metadata[:ignore_console_errors] ||= false
    example.metadata[:ignore_form_failures] ||= false
    driven_by :selenium_chrome_headless
  end

  config.after(:each, type: :system, js: true, ignore_console_errors: false, ignore_form_failures: false) do
    excludes = [
      "assets/tailwindcss" # We need to ignore assets/tailwindcss as we get 404 errors on development.
    ]
    assert_no_console_errors(page, excludes)
  end

  config.after(:each, type: :system, js: true, ignore_console_errors: false, ignore_form_failures: true) do
    excludes = [
      "assets/tailwindcss", # We need to ignore assets/tailwindcss as we get 404 errors on development.
      "Failed to load resource: the server responded with a status of 422" # Form errors respond with 422, and turbo outputs this to the console
    ]
    assert_no_console_errors(page, excludes)
  end

  config.after(:each, type: :system, js: true, ignore_console_errors: true) do
    # Clear browser logs for subsequent examples.
    page.driver.browser.logs.get(:browser)
  end
end
