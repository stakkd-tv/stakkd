RSpec.shared_examples "collection action buttons" do
  before do
    assign(:collection_status, :completed)
    assign(:collection_statuses, {collection_record => :completed})
  end

  it "renders the collection action with its paths when authenticated" do
    allow(view).to receive(:authenticated?).and_return(true)
    def view.current_user = FactoryBot.build_stubbed(:user)
    expect(Manage::Collection).not_to receive(:new)
    render
    prefix = "button[data-controller='collection-button'][data-record-type='#{collection_record.class.polymorphic_name}'][data-record-id='#{collection_record.id}']"
    assert_select prefix, count: 1
    ["collection", "add_to_collection", "remove_collection_formats", "remove_from_collection"].zip(
      ["state", "add", "remove-formats", "remove"]
    ).each do |action, attribute|
      assert_select "#{prefix}[data-collection-button-#{attribute}-url-value='#{view.polymorphic_record_path(collection_record, action)}']"
    end
    assert_select "#{prefix}[data-status='completed']"
  end

  it "does not render collection actions for visitors" do
    allow(view).to receive(:authenticated?).and_return(false)
    render
    assert_select "button[data-controller='collection-button']", count: 0
  end

  [:none, :partial].each do |status|
    it "renders the supplied #{status} collection status" do
      allow(view).to receive(:authenticated?).and_return(true)
      def view.current_user = FactoryBot.build_stubbed(:user)
      assign(:collection_status, status)
      assign(:collection_statuses, {collection_record => status})
      render
      assert_select "button[data-controller='collection-button'][data-record-type='#{collection_record.class.polymorphic_name}'][data-record-id='#{collection_record.id}'][data-status='#{status}']"
    end
  end

  it "disables collection actions for unreleased items" do
    allow(view).to receive(:authenticated?).and_return(true)
    def view.current_user = FactoryBot.build_stubbed(:user)
    allow_any_instance_of(collection_record.class).to receive(:released?).and_return(false)
    render
    assert_select "button[data-controller='collection-button'][data-record-type='#{collection_record.class.polymorphic_name}'][data-record-id='#{collection_record.id}'][disabled]"
  end
end
