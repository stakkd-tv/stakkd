require "rails_helper"

RSpec.describe "jobs/index.json", type: :view do
  before(:each) do
    @j1 = FactoryBot.create(:job, name: "Actor")
    @j2 = FactoryBot.create(:job, name: "Producer")
    assign(:jobs, [@j1, @j2])
  end

  it "renders json" do
    render
    json = JSON.parse(rendered)
    expect(json).to be_an(Array)
    expect(json[0]["value"]).to eq @j1.id
    expect(json[0]["label"]).to eq @j1.name
    expect(json[0]["image_url"]).to be_nil
    expect(json[1]["value"]).to eq @j2.id
    expect(json[1]["label"]).to eq @j2.name
    expect(json[1]["image_url"]).to be_nil
  end
end
