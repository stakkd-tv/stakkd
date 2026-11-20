RSpec.shared_examples "a model with collection actions" do
  let(:user) { FactoryBot.create(:user) }

  def collection_action_path(action)
    public_send("#{action}_#{record.route_name}_path", record.records_for_polymorphic_paths)
  end

  before do
    allow(Current).to receive(:session).and_return(Session.new(user:))
    allow(Current).to receive(:user).and_return(user)
    CollectionFormat::COMMON_NAMES.each { |name| FactoryBot.create(:collection_format, :common, name:) }
  end

  describe "GET collection" do
    it "returns ownership, format choices and status for the signed-in user" do
      Manage::Collection.new(user).add!(record, formats: ["Blu-ray"])
      other = FactoryBot.create(:user)
      FactoryBot.create(:collection_format, user: other, name: "Private format")
      get collection_action_path("collection")
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to include("owned" => 1, "total" => 1, "can_add" => true)
      expect(response.parsed_body["formats"].map { |format| format["name"] }).not_to include("Private format")
      expect(response.parsed_body["affected_items"]["#{record.class.polymorphic_name}:#{record.id}"]).to eq("completed")
    end

    it "requires authentication" do
      allow(Current).to receive(:session).and_return(nil)
      allow(Current).to receive(:user).and_return(nil)
      get collection_action_path("collection")
      expect(response).to redirect_to(new_session_path)
    end
  end

  describe "POST add_to_collection" do
    it "saves common and inline custom formats without changing history or watchlist" do
      common = CollectionFormat.common.find_by!(name: "Blu-ray")
      user.watchlist!.add!(record)
      post collection_action_path("add_to_collection"), params: {scope: "all", format_ids: [common.id], custom_formats: ["VHS"]}
      expect(response).to have_http_status(:ok)
      expect(user.collection_items.count).to eq(1)
      expect(user.collection_formats.pluck(:name)).to eq(["VHS"])
      expect(user.history_items.count).to eq(0)
      expect(user.watchlisted?(record)).to be(true)
    end

    it "rejects an invalid scope or format id without changes" do
      [{scope: "invalid"}, {format_ids: ["invalid"]}, {custom_formats: [" "]}].each do |params|
        post collection_action_path("add_to_collection"), params: params
        expect(response).to have_http_status(:unprocessable_content)
        expect(response.parsed_body["errors"]).not_to be_empty
      end
      expect(user.collection_items.count).to eq(0)
    end

    it "does not accept another user's format" do
      custom = FactoryBot.create(:collection_format)
      post collection_action_path("add_to_collection"), params: {format_ids: [custom.id]}
      expect(response).to have_http_status(:unprocessable_content)
      expect(user.collection_items.count).to eq(0)
    end

    it "ignores a supplied owner id" do
      other = FactoryBot.create(:user)
      post collection_action_path("add_to_collection"), params: {user_id: other.id}
      expect(response).to have_http_status(:ok)
      expect(user.collection_items.count).to eq(1)
      expect(other.collection_items.count).to eq(0)
    end

    it "requires authentication" do
      allow(Current).to receive(:session).and_return(nil)
      allow(Current).to receive(:user).and_return(nil)
      post collection_action_path("add_to_collection")
      expect(response).to redirect_to(new_session_path)
    end
  end

  describe "DELETE remove_collection_formats" do
    it "removes a format but retains ownership" do
      Manage::Collection.new(user).add!(record, formats: ["VHS"])
      format = user.collection_formats.first!
      delete collection_action_path("remove_collection_formats"), params: {format_ids: [format.id]}
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["owned"]).to eq(1)
      expect(CollectionFormat.exists?(format.id)).to be(false)
    end

    it "rejects another user's format" do
      format = FactoryBot.create(:collection_format)
      delete collection_action_path("remove_collection_formats"), params: {format_ids: [format.id]}
      expect(response).to have_http_status(:unprocessable_content)
    end

    it "requires authentication" do
      allow(Current).to receive(:session).and_return(nil)
      allow(Current).to receive(:user).and_return(nil)
      delete collection_action_path("remove_collection_formats")
      expect(response).to redirect_to(new_session_path)
    end
  end

  describe "DELETE remove_from_collection" do
    it "removes ownership only for the signed-in user" do
      other = FactoryBot.create(:user)
      [user, other].each { |owner| Manage::Collection.new(owner).add!(record, formats: ["VHS"]) }
      delete collection_action_path("remove_from_collection")
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["owned"]).to eq(0)
      expect(other.collection_items.count).to eq(1)
    end

    it "requires authentication" do
      allow(Current).to receive(:session).and_return(nil)
      allow(Current).to receive(:user).and_return(nil)
      delete collection_action_path("remove_from_collection")
      expect(response).to redirect_to(new_session_path)
    end
  end
end
