require "rails_helper"

RSpec.describe "people/show", type: :view do
  let(:alias) { "Elias" }
  let(:biography) { "This is bio" }
  let(:gender) { "male" }
  let(:imdb_id) { "Imdb" }
  let(:known_for) { "acting" }
  let(:dob) { Date.new(2025, 1, 1) }
  let(:dod) { Date.new(2026, 1, 1) }
  let(:possible_tabs) { [] }

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
    gallery_presenter = Galleries::Presenter.new(@person)
    movie = FactoryBot.create(:movie, translated_title: "Spooder-man")
    show = FactoryBot.create(:show, translated_title: "Baking bread")
    credits = [
      {year: nil, credits: {movie => {"Bob" => 1}}},
      {year: 2026, credits: {show => {"Charles" => 16}}}
    ]
    assign(:person, @person)
    assign(:possible_tabs, possible_tabs)
    assign(:credit_type, possible_tabs.first)
    assign(:credits, credits)
    assign(:gallery_presenter, gallery_presenter)
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
  end

  it "renders the galleries" do
    render
    assert_select "label", text: "Images"
    assert_select "img[src*='300x450.png']"
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

  context "when there are no possible tabs" do
    let(:possible_tabs) { [] }

    it "does not the credits section" do
      render
      assert_select "turbo-frame#credits", count: 0
    end

    it "does not render any credits" do
    end
  end

  context "when there are possible tabs" do
    let(:possible_tabs) { ["cast", "crew"] }

    it "renders credits section" do
      render
      assert_select "turbo-frame#credits"
      assert_select "a[href='?credit_type=cast'][class='link text-pop hover:bg-background-darker']", text: "Cast Credits"
      assert_select "a[href='?credit_type=crew'][class='link']", text: "Crew Credits"
    end

    it "renders the credits" do
      render
      assert_select "turbo-frame#credits" do
        assert_select "p.font-domine", text: "TBA"
        assert_select "p.font-domine", text: "2026"
        assert_select "a[href='#{movie_path(Movie.first)}']", text: "Spooder-man"
        assert_select "a[href='#{show_path(Show.first)}']", text: "Baking bread"
        assert_select "small", text: "Bob"
        assert_select "small", text: "Charles (16 episodes)"
      end
    end
  end
end
