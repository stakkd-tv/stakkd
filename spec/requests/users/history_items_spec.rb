require "rails_helper"

RSpec.describe "Users::HistoryItems", type: :request do
  describe "DELETE /users/:user_id/history_items/:id" do
    let(:user) { FactoryBot.create(:user, :confirmed) }

    before do
      allow(Current).to receive(:session).and_return(Session.new(user:))
      allow(Current).to receive(:user).and_return(user)
    end

    it "deletes the signed-in user's item and responds with JSON" do
      item = FactoryBot.create(:history_item, user:)

      expect {
        delete user_history_item_path(user, item), headers: {"Accept" => "application/json"}
      }.to change { HistoryItem.exists?(item.id) }.from(true).to(false)

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to eq({"success" => true})
    end

    it "rejects deletion through another user's history" do
      item = FactoryBot.create(:history_item)

      expect {
        delete user_history_item_path(item.user, item)
      }.not_to change { HistoryItem.exists?(item.id) }

      expect(response).to redirect_to user_path(item.user)
    end

    it "cannot find another user's item through the signed-in user's history" do
      item = FactoryBot.create(:history_item)

      expect {
        delete user_history_item_path(user, item)
      }.not_to change { HistoryItem.exists?(item.id) }

      expect(response).to have_http_status(:not_found)
    end
  end
end
