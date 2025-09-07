require "rails_helper"

RSpec.describe "Shows Keywords", type: :request do
  let(:show) { FactoryBot.create(:show) }
  let(:valid_attributes) {
    {
      tag: "Hello there"
    }
  }

  describe "GET /shows/:show_id/keywords" do
    context "when user is not signed in" do
      it "redirects to the user sign in page" do
        get show_keywords_path(show_id: show)
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
        get show_keywords_path(show_id: show)
        expect(response).to be_successful
      end
    end
  end

  describe "POST /shows/:show_id/keywords" do
    context "when user is not signed in" do
      it "redirects to the user sign in page" do
        post show_keywords_path(show_id: show), params: valid_attributes
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
        it "adds keywords" do
          post show_keywords_path(show_id: show), params: valid_attributes
          expect(show.reload.keyword_list).to eq ["Hello there"]
        end

        it "redirects to the keywords index path" do
          post show_keywords_path(show_id: show), params: valid_attributes
          expect(response).to redirect_to show_keywords_path(show_id: show)
        end
      end
    end
  end

  describe "DELETE /shows/:show_id/keywords/:id" do
    context "when user is not signed in" do
      it "redirects to the user sign in page" do
        show.keyword_list.add("hello there")
        show.save
        tagging = show.keyword_taggings.first
        delete show_keyword_path(tagging, show_id: show)
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

      it "removes the keyword" do
        show.keyword_list.add("hello there")
        show.save
        tagging = show.keyword_taggings.first
        delete show_keyword_path(tagging, show_id: show)
        expect(show.reload.keyword_list).to eq []
      end

      it "renders no content" do
        show.keyword_list.add("hello there")
        show.save
        tagging = show.keyword_taggings.first
        delete show_keyword_path(tagging, show_id: show)
        expect(response).to be_no_content
      end
    end
  end
end
