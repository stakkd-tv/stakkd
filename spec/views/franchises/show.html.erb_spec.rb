require "rails_helper"

RSpec.describe "franchises/show", type: :view do
  let(:posters) { [] }
  let(:backgrounds) { [] }
  let(:logos) { [] }

  before(:each) do
    def view.authenticated? = false
    @franchise = FactoryBot.create(
      :franchise,
      original_title: "Original Title",
      translated_title: "Translated Title",
      overview: "This is overview",
      homepage: "https://google.com",
      posters:,
      backgrounds:,
      logos:
    )
    @movie = FactoryBot.create(:movie, :with_release_date, date_for_release: Date.today, translated_title: "Great Movie")
    FactoryBot.create(:franchise_item, franchise: @franchise, record: @movie)
    @show = FactoryBot.create(:show, :with_premiere_date, date_for_premiere: Date.tomorrow, translated_title: "Great Show")
    FactoryBot.create(:franchise_item, franchise: @franchise, record: @show)
    @show_no_air_date = FactoryBot.create(:show, translated_title: "No air date")
    FactoryBot.create(:franchise_item, franchise: @franchise, record: @show_no_air_date)
    gallery_presenter = Galleries::Presenter.new(@franchise)
    assign(:franchise, @franchise)
    assign(:gallery_presenter, gallery_presenter)
  end

  it "renders attributes" do
    render
    expect(rendered).to match(/Translated Title/)
    expect(rendered).to match(/This is overview/)
    assert_select "a[href='https://google.com']"
  end

  it "renders the franchise items" do
    render
    assert_select "#franchise_items" do
      assert_select "h4", text: "3 Items"
      assert_select "p", text: "Great Movie"
      assert_select "small", text: Date.today.strftime("%B %d, %Y")
      assert_select "a[href='#{movie_path(Movie.last)}']"
      assert_select "p", text: "Great Show"
      assert_select "small", text: Date.tomorrow.strftime("%B %d, %Y")
      assert_select "a[href='#{show_path(Show.first)}']"
      assert_select "p", text: "No air date"
      assert_select "a[href='#{show_path(Show.second)}']"
    end
  end

  it "renders the add to history dialog" do
    render
    assert_select "dialog[data-controller='history-dialog']"
  end

  it "renders the add to history buttons for each history item when authenticated" do
    allow(view).to receive(:authenticated?).and_return(true)
    render
    assert_select "button[title='Add to history'][data-history-button-add-to-history-url-value='#{add_to_history_movie_path(@movie)}']"
    assert_select "button[title='Add to history'][data-history-button-add-to-history-url-value='#{add_to_history_show_path(@show)}']"
    assert_select "button[title='Add to history'][data-history-button-add-to-history-url-value='#{add_to_history_show_path(@show_no_air_date)}']"
  end

  context "when the franchise has a background" do
    let(:backgrounds) { [Rack::Test::UploadedFile.new("spec/support/assets/300x450.png", "image/png")] }

    it "renders the background header" do
      render
      assert_select "img[class='w-full min-h-96 object-cover blur-xs'][src*='300x450.png']"
    end

    it "renders the backgrounds section" do
      render
      assert_select "label", text: "Backgrounds"
      assert_select "img[src*='300x450.png']", count: 2
    end
  end

  context "when the franchise has a poster" do
    let(:posters) { [Rack::Test::UploadedFile.new("spec/support/assets/300x450.png", "image/png")] }

    it "renders the posters section" do
      render
      assert_select "label", text: "Posters"
      assert_select "img[src*='300x450.png']", count: 2 # One for poster, the other in the gallery section
    end
  end

  context "when the franchise has a logo" do
    let(:logos) { [Rack::Test::UploadedFile.new("spec/support/assets/300x450.png", "image/png")] }

    it "renders the posters section" do
      render
      assert_select "label", text: "Logos"
      assert_select "img[src*='300x450.png']", count: 1
    end
  end
end
