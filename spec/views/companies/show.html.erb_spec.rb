require "rails_helper"

RSpec.describe "companies/show", type: :view do
  let(:homepage) { "https://google.com" }
  let(:assignment_count) { 0 }

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
    assignment_count.times do
      FactoryBot.create(:company_assignment, company: @company, record: FactoryBot.build(:movie, :with_release_date, translated_title: "Berk to Future", overview: "This is a movie", date_for_release: Date.today))
    end
    assign(:company, @company)
    assign(:gallery_presenter, gallery_presenter)
    assign(:company_assignments, @company.company_assignments.paginate(page: 1, per_page: 2))
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

  context "when there are company assignments" do
    let(:assignment_count) { 1 }

    it "renders the company assignments" do
      render
      assert_select "a[href*='/movies/']", text: "Berk to Future"
    end
  end

  context "when there is no next page for company assignments" do
    let(:assignment_count) { 2 }

    it "does not render the next page link" do
      render
      assert_select "a[href*='#{company_path(@company, page: 2)}']", count: 0
    end
  end

  context "when there is a next page for company assignments" do
    let(:assignment_count) { 3 }

    it "renders the next page link" do
      render
      assert_select "a[href*='#{company_path(@company, page: 2)}']"
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
