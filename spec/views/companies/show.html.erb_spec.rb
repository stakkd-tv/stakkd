require "rails_helper"

RSpec.describe "companies/show", type: :view do
  let(:homepage) { "https://google.com" }

  before(:each) do
    def view.authenticated? = true
    @company = FactoryBot.create(
      :company,
      name: "test name",
      description: "this is a description",
      homepage:,
      logos: [Rack::Test::UploadedFile.new("spec/support/assets/300x450.png", "image/png")]
    )
    assign(:company, @company)
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/test name/)
    expect(rendered).to match(/this is a description/)
    assert_select "a[href='#{edit_company_path(@company)}']"
    assert_select "a[href='#{@company.homepage}']"
    assert_select "small", text: "TIP: Double click an image to like it."
  end

  context "when not authenticated" do
    before do
      def view.authenticated? = false
    end

    it "does not render user specific features" do
      assert_select "small", text: "TIP: Double click an image to like it.", count: 0
    end
  end

  context "when there is no homepage" do
    let(:homepage) { "" }

    it "does not render homepage" do
      render
      assert_select "i.fa-globe", count: 0
    end
  end
end
