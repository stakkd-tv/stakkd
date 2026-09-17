require "rails_helper"

RSpec.describe "layouts/application.html.erb", type: :view do
  it "renders all dialogs" do
    def view.authenticated? = false
    def view.current_user = nil
    render
    assert_select "dialog", count: 3
    assert_select "dialog[data-controller='history-dialog']"
    assert_select "dialog[data-controller='stack-dialog']"
    assert_select "dialog[data-controller='deletion-dialog']"
  end
end
