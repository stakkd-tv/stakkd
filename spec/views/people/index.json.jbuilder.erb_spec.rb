require "rails_helper"

RSpec.describe "people/index.json", type: :view do
  before(:each) do
    @p1 = FactoryBot.create(:person, translated_name: "Oscar Piastri")
    @p2 = FactoryBot.create(:person, translated_name: "Lewis Hamilton")
    assign(:people, [@p1, @p2])
  end

  it "renders json" do
    render
    json = JSON.parse(rendered)
    expect(json).to be_an(Array)
    expect(json[0]["value"]).to eq @p1.id
    expect(json[0]["label"]).to eq @p1.translated_name
    expect(json[0]["image_url"]).to be_nil
    expect(json[1]["value"]).to eq @p2.id
    expect(json[1]["label"]).to eq @p2.translated_name
    expect(json[1]["image_url"]).to be_nil
  end
end
