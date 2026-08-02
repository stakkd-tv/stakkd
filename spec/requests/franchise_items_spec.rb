require "rails_helper"

RSpec.describe "FranchiseItems", type: :request do
  let(:movie) { FactoryBot.create(:movie) }
  let(:franchise) { FactoryBot.create(:franchise) }
  let(:valid_attributes) {
    {
      record_type: "Movie",
      record_id: movie.id
    }
  }

  let(:invalid_attributes) {
    valid_attributes.merge({
      record_id: nil
    })
  }

  describe "GET /franchises/:franchise_id/items/editor" do
    context "when user is not signed in" do
      it "redirects to the user sign in page" do
        get editor_franchise_franchise_items_path(franchise_id: franchise)
        expect(response).to redirect_to new_session_path
      end
    end

    context "when user is signed in" do
      before do
        user = FactoryBot.create(:user)
        session = Session.new(user:)
        allow(Current).to receive(:session).and_return(session)
        allow(Current).to receive(:user).and_return(user)
      end

      it "renders a successful response" do
        get editor_franchise_franchise_items_path(franchise_id: franchise)
        expect(response).to be_successful
      end
    end
  end

  describe "POST /franchises/:franchise_id/items" do
    context "when user is not signed in" do
      it "redirects to the user sign in page" do
        post franchise_franchise_items_path(franchise_id: franchise), params: {franchise_item: valid_attributes}
        expect(response).to redirect_to new_session_path
      end
    end

    context "when user is signed in" do
      before do
        user = FactoryBot.create(:user)
        session = Session.new(user:)
        allow(Current).to receive(:session).and_return(session)
        allow(Current).to receive(:user).and_return(user)
      end

      context "with valid params" do
        it "creates a franchise item" do
          post franchise_franchise_items_path(franchise_id: franchise), params: {franchise_item: valid_attributes}
          franchise_item = FranchiseItem.includes(:record, :franchise).last
          expect(franchise_item.record).to eq movie
          expect(franchise_item.franchise).to eq franchise
        end

        it "redirects to the franchise items editor path" do
          post franchise_franchise_items_path(franchise_id: franchise), params: {franchise_item: valid_attributes}
          expect(response).to redirect_to editor_franchise_franchise_items_path(franchise_id: franchise)
        end
      end

      context "with invalid params" do
        it "does not create a franchise item" do
          post franchise_franchise_items_path(franchise_id: franchise), params: {franchise_item: invalid_attributes}
          expect(FranchiseItem.count).to eq 0
        end

        it "redirects to the franchise items editor path with a flash alert" do
          post franchise_franchise_items_path(franchise_id: franchise), params: {franchise_item: invalid_attributes}
          expect(response).to redirect_to editor_franchise_franchise_items_path(franchise_id: franchise)
          expect(flash[:alert]).to eq "Item could not be added."
        end
      end

      context "when record type is not valid" do
        it "does not create a franchise item" do
          season = FactoryBot.create(:season)
          post franchise_franchise_items_path(franchise_id: franchise), params: {franchise_item: {record_id: season.id, record_type: season.class.name}}
          expect(FranchiseItem.count).to eq 0
        end

        it "redirects to the franchise items editor path with a flash alert" do
          season = FactoryBot.create(:season)
          post franchise_franchise_items_path(franchise_id: franchise), params: {franchise_item: {record_id: season.id, record_type: season.class.name}}
          expect(response).to redirect_to editor_franchise_franchise_items_path(franchise_id: franchise)
          expect(flash[:alert]).to eq "Record type is invalid."
        end
      end
    end
  end

  describe "DELETE /franchises/:franchise_id/franchise_items/:id" do
    context "when user is not signed in" do
      it "redirects to the user sign in page" do
        franchise_item = franchise.franchise_items.create!(valid_attributes)
        delete franchise_franchise_item_path(franchise_item, franchise_id: franchise)
        expect(response).to redirect_to new_session_path
      end
    end

    context "when user is signed in" do
      before do
        user = FactoryBot.create(:user)
        session = Session.new(user:)
        allow(Current).to receive(:session).and_return(session)
        allow(Current).to receive(:user).and_return(user)
      end

      it "removes the franchise_item" do
        franchise_item = franchise.franchise_items.create!(valid_attributes)
        delete franchise_franchise_item_path(franchise_item, franchise_id: franchise)
        expect(franchise.reload.franchise_items).to eq []
      end

      it "renders no content" do
        franchise_item = franchise.franchise_items.create!(valid_attributes)
        delete franchise_franchise_item_path(franchise_item, franchise_id: franchise)
        expect(response).to be_no_content
      end
    end
  end
end
