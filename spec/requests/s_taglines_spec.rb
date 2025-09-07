require "rails_helper"

RSpec.describe "Shows Taglines", type: :request do
  let(:show) { FactoryBot.create(:show) }
  let(:country) { FactoryBot.create(:country) }
  let(:valid_attributes) {
    {
      tagline: "Test tag"
    }
  }

  let(:invalid_attributes) {
    valid_attributes.merge({
      tagline: nil
    })
  }

  describe "GET /shows/:show_id/taglines" do
    context "when user is not signed in" do
      it "redirects to the user sign in page" do
        get show_taglines_path(show_id: show)
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
        get show_taglines_path(show_id: show)
        expect(response).to be_successful
      end
    end
  end

  describe "POST /shows/:show_id/taglines" do
    context "when user is not signed in" do
      it "redirects to the user sign in page" do
        post show_taglines_path(show_id: show), params: {tagline: valid_attributes}
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
        it "creates a tagline" do
          post show_taglines_path(show_id: show), params: {tagline: valid_attributes}
          tagline = Tagline.last
          expect(tagline.record).to eq show
          expect(tagline.tagline).to eq "Test tag"
        end

        it "redirects to the taglines index path" do
          post show_taglines_path(show_id: show), params: {tagline: valid_attributes}
          expect(response).to redirect_to show_taglines_path(show_id: show)
        end
      end

      context "with invalid params" do
        it "does not create a tagline" do
          post show_taglines_path(show_id: show), params: {tagline: invalid_attributes}
          expect(Tagline.count).to eq 0
        end

        it "redirects to the taglines index path with a flash alert" do
          post show_taglines_path(show_id: show), params: {tagline: invalid_attributes}
          expect(response).to redirect_to show_taglines_path(show_id: show)
          expect(flash[:alert]).to eq "Could not add that tagline."
        end
      end
    end
  end

  describe "PATCH /shows/:show_id/taglines/:id" do
    let(:new_attributes) {
      {
        tagline: "New tag"
      }
    }

    context "when user is not signed in" do
      it "redirects to the user sign in page" do
        tagline = show.taglines.create!(valid_attributes)
        patch show_tagline_path(tagline, show_id: show), params: {tagline: new_attributes}
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
        it "updates the tagline" do
          tagline = show.taglines.create!(valid_attributes)
          patch show_tagline_path(tagline, show_id: show), params: {tagline: new_attributes}
          tagline.reload
          expect(tagline.tagline).to eq "New tag"
        end

        it "renders json" do
          tagline = show.taglines.create!(valid_attributes)
          patch show_tagline_path(tagline, show_id: show), params: {tagline: new_attributes}
          expect(response).to be_successful
          json = JSON.parse(response.body)
          expect(json).to eq({
            "success" => true
          })
        end
      end

      context "with invalid params" do
        it "does not update the tagline" do
          tagline = show.taglines.create!(valid_attributes)
          patch show_tagline_path(tagline, show_id: show), params: {tagline: invalid_attributes}
          tagline.reload
          expect(tagline.tagline).to eq "Test tag"
        end

        it "renders json with errors" do
          tagline = show.taglines.create!(valid_attributes)
          patch show_tagline_path(tagline, show_id: show), params: {tagline: invalid_attributes}
          expect(response.status).to eq 422
          json = JSON.parse(response.body)
          expect(json).to eq({
            "success" => false,
            "errors" => [
              {"tagline" => ["Tagline can't be blank"]}
            ]
          })
        end
      end
    end
  end

  describe "DELETE /shows/:show_id/taglines/:id" do
    context "when user is not signed in" do
      it "redirects to the user sign in page" do
        tagline = show.taglines.create!(valid_attributes)
        delete show_tagline_path(tagline, show_id: show)
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

      it "removes the tagline" do
        show.taglines.create!(valid_attributes)
        tagline = show.taglines.first
        delete show_tagline_path(tagline, show_id: show)
        expect(show.reload.taglines).to eq []
      end

      it "renders no content" do
        show.taglines.create!(valid_attributes)
        tagline = show.taglines.first
        delete show_tagline_path(tagline, show_id: show)
        expect(response).to be_no_content
      end
    end
  end

  describe "POST /shows/:show_id/taglines/:id/move" do
    context "when user is not signed in" do
      it "redirects to the user sign in page" do
        tagline = show.taglines.create!(valid_attributes)
        post move_show_tagline_path(tagline, show_id: show)
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

      it "updates the tagline position" do
        tagline = show.taglines.create!(valid_attributes)
        post move_show_tagline_path(tagline, show_id: show), params: {position: 2}
        expect(response).to be_successful
        expect(tagline.reload.position).to eq 2
      end
    end
  end
end
