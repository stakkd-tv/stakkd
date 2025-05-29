require "rails_helper"

RSpec.describe "people/show", type: :view do
  let(:alias) { "Elias" }
  let(:biography) { "This is bio" }
  let(:gender) { "male" }
  let(:imdb_id) { "Imdb" }
  let(:known_for) { "acting" }
  let(:dob) { Date.new(2025, 1, 1) }
  let(:dod) { Date.new(2026, 1, 1) }

  before(:each) do
    def view.authenticated? = true
    @person = FactoryBot.create(
      :person,
      alias:,
      biography:,
      gender:,
      imdb_id:,
      known_for:,
      dob:,
      dod:,
      original_name: "Original Name",
      translated_name: "Translated Name",
      images: [Rack::Test::UploadedFile.new("spec/support/assets/300x450.png", "image/png")]
    )
    assign(:person, @person)
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Elias/)
    expect(rendered).to match(/This is bio/)
    expect(rendered).to match(/Male/)
    expect(rendered).to match(/Acting/)
    expect(rendered).to match(/\(Original Name\)/)
    expect(rendered).to match(/Translated Name/)
    assert_select "a[href='#{edit_person_path(@person)}']"
    assert_select "a[href='#{@person.imdb_url}']"
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

  context "when there is no alias" do
    let(:alias) { "" }

    it "does not render alias" do
      render
      assert_select "p.font-domine", text: "AKA:", count: 0
    end
  end

  context "when there is alias" do
    it "does not render alias" do
      render
      assert_select "p.font-domine", text: "AKA:", count: 1
    end
  end

  context "when there is no age" do
    let(:dob) { nil }

    it "does not render age" do
      render
      assert_select "p.font-domine", text: "Age:", count: 0
    end
  end

  context "when there is age" do
    it "renders age" do
      render
      assert_select "p.font-domine", text: "Age:", count: 1
    end
  end

  context "when there is no dob" do
    let(:dob) { nil }

    it "does not render dob" do
      render
      assert_select "p.font-domine", text: "Date of birth:", count: 0
    end
  end

  context "when there is dob" do
    it "renders dob" do
      render
      assert_select "p.font-domine", text: "Date of birth:", count: 1
    end
  end

  context "when there is no dod" do
    let(:dod) { nil }

    it "does not render dod" do
      render
      assert_select "p.font-domine", text: "Date of death:", count: 0
    end
  end

  context "when there is dod" do
    it "renders dod" do
      render
      assert_select "p.font-domine", text: "Date of death:", count: 1
    end
  end

  context "when there is gender" do
    it "renders gender" do
      render
      assert_select "p.font-domine", text: "Gender:", count: 1
    end
  end

  context "when there is no known for" do
    let(:known_for) { "" }

    it "does not render known for" do
      render
      assert_select "p.font-domine", text: "Known for:", count: 0
    end
  end

  context "when there is known for" do
    it "renders known for" do
      render
      assert_select "p.font-domine", text: "Known for:", count: 1
    end
  end
end
