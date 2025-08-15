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
    gallery_presenter = Galleries::Presenter.new(@company)
    assign(:company, @company)
    assign(:gallery_presenter, gallery_presenter)
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/test name/)
    expect(rendered).to match(/this is a description/)
    assert_select "a[href='#{edit_company_path(@company)}']"
    assert_select "a[href='#{@company.homepage}']"
  end

  it "renders the galleries" do
    render
    assert_select "label", text: "Logos"
    assert_select "img[src*='300x450.png']"
  end

  context "when there is no homepage" do
    let(:homepage) { "" }

    it "does not render homepage" do
      render
      assert_select "i.fa-globe", count: 0
    end
  end
end
