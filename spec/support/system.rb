Capybara.register_driver :selenium_chrome_headless do |app|
  args = ["--headless=new", "--window-size=1280,2560"]
  options = Selenium::WebDriver::Chrome::Options.new(args:)
  Capybara::Selenium::Driver.new(app, browser: :chrome, options:)
end

Capybara.register_driver :selenium_chrome_headless_mobile do |app|
  args = ["--headless=new", "--window-size=500,1000"]
  options = Selenium::WebDriver::Chrome::Options.new(args:)
  Capybara::Selenium::Driver.new(app, browser: :chrome, options:)
end

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :rack_test
  end

  config.before(:each, type: :system, js: true) do |example|
    example.metadata[:ignore_console_errors] ||= false
    driven_by :selenium_chrome_headless
  end

  config.after(:each, type: :system, js: true, ignore_console_errors: false) do
    errors = page.driver.browser.logs.get(:browser).select { _1.level == "SEVERE" }
    if errors.present?
      message = errors.map(&:message).join("\n")
      raise "Failed due to browser console errors: #{message}"
    end
  end

  config.after(:each, type: :system, js: true, ignore_console_errors: true) do
    # Clear browser logs for subsequent examples.
    page.driver.browser.logs.get(:browser)
  end
end
