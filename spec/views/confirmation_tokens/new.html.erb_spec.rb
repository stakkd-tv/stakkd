require "rails_helper"

RSpec.describe "confirmation_tokens/new.html.erb", type: :view do
  it "renders a form with email address" do
    render
    expect(rendered).to have_selector("form[action='/confirmations']")
    expect(rendered).to have_selector("input[type='email']")
  end
end
