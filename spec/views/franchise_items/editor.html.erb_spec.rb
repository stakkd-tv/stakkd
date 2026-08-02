require "rails_helper"

RSpec.describe "franchise_items/editor", type: :view do
  let(:franchise) { FactoryBot.create(:franchise) }

  before(:each) do
    assign(:franchise, franchise)
    assign(:table_presenter, Tabulator::FranchiseItemsPresenter.new(franchise.franchise_items))
  end

  it "renders the table editor" do
    render
    assert_select "div[data-controller='table-editor']"
    assert_select "div[data-table-editor-path-prefix-value='#{franchise_franchise_items_path(franchise)}']"
    assert_select "div[data-table-editor-model-name-value='franchise_item']"
  end

  it "renders the new franchise item form" do
    render
    assert_select "form[action='#{franchise_franchise_items_path(franchise)}']" do
      assert_select "input[name='franchise_item[record_id]']"
      assert_select "input[name='franchise_item[record_type]']"
    end
  end
end
