require "rails_helper"

RSpec.describe "companies/show", type: :view do
  before(:each) do
    assign(:company, Company.create!(
      description: "Description",
      homepage: "Homepage",
      name: "Name"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Description/)
    expect(rendered).to match(/Homepage/)
    expect(rendered).to match(/Name/)
  end
end
