require "rails_helper"

RSpec.describe "Shows CastMembers", type: :request do
  let(:show) { FactoryBot.create(:show) }
  let(:person) { FactoryBot.create(:person) }
  let(:valid_attributes) {
    {
      person_id: person.id,
      character: "Test character"
    }
  }

  let(:invalid_attributes) {
    valid_attributes.merge({
      person_id: nil,
      character: nil
    })
  }

  describe "GET /shows/:show_id/cast_members" do
    context "when user is not signed in" do
      it "redirects to the user sign in page" do
        get show_cast_members_path(show_id: show)
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
        get show_cast_members_path(show_id: show)
        expect(response).to be_successful
      end
    end
  end

  describe "POST /shows/:show_id/cast_members" do
    context "when user is not signed in" do
      it "redirects to the user sign in page" do
        post show_cast_members_path(show_id: show), params: {cast_member: valid_attributes}
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
        it "creates an cast member" do
          post show_cast_members_path(show_id: show), params: {cast_member: valid_attributes}
          cast_member = CastMember.last
          expect(cast_member.record).to eq show
          expect(cast_member.person).to eq person
          expect(cast_member.character).to eq "Test character"
        end

        it "redirects to the cast members index path" do
          post show_cast_members_path(show_id: show), params: {cast_member: valid_attributes}
          expect(response).to redirect_to show_cast_members_path(show_id: show)
        end
      end

      context "with invalid params" do
        it "does not create an cast member" do
          post show_cast_members_path(show_id: show), params: {cast_member: invalid_attributes}
          expect(CastMember.count).to eq 0
        end

        it "redirects to the cast members index path with a flash alert" do
          post show_cast_members_path(show_id: show), params: {cast_member: invalid_attributes}
          expect(response).to redirect_to show_cast_members_path(show_id: show)
          expect(flash[:alert]).to eq "Could not add that cast member."
        end
      end
    end
  end

  describe "PATCH /shows/:show_id/cast_members/:id" do
    let(:new_person) { FactoryBot.create(:person) }
    let(:new_attributes) {
      {
        person_id: new_person.id,
        character: "New character"
      }
    }

    context "when user is not signed in" do
      it "redirects to the user sign in page" do
        cast_member = show.cast_members.create!(valid_attributes)
        patch show_cast_member_path(cast_member, show_id: show), params: {cast_member: new_attributes}
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
        it "updates the cast member" do
          cast_member = show.cast_members.create!(valid_attributes)
          patch show_cast_member_path(cast_member, show_id: show), params: {cast_member: new_attributes}
          cast_member.reload
          expect(cast_member.person).to eq new_person
          expect(cast_member.character).to eq "New character"
        end

        it "renders json" do
          cast_member = show.cast_members.create!(valid_attributes)
          patch show_cast_member_path(cast_member, show_id: show), params: {cast_member: new_attributes}
          expect(response).to be_successful
          json = JSON.parse(response.body)
          expect(json).to eq({
            "success" => true
          })
        end
      end

      context "with invalid params" do
        it "does not update the cast member" do
          cast_member = show.cast_members.create!(valid_attributes)
          patch show_cast_member_path(cast_member, show_id: show), params: {cast_member: invalid_attributes}
          cast_member.reload
          expect(cast_member.person).to eq person
          expect(cast_member.character).to eq "Test character"
        end

        it "renders json with errors" do
          cast_member = show.cast_members.create!(valid_attributes)
          patch show_cast_member_path(cast_member, show_id: show), params: {cast_member: invalid_attributes}
          expect(response.status).to eq 422
          json = JSON.parse(response.body)
          expect(json).to eq({
            "success" => false,
            "errors" => [
              {"person" => ["Person must exist"]},
              {"character" => ["Character can't be blank"]}
            ]
          })
        end
      end
    end
  end

  describe "DELETE /shows/:show_id/cast_members/:id" do
    context "when user is not signed in" do
      it "redirects to the user sign in page" do
        cast_member = show.cast_members.create!(valid_attributes)
        delete show_cast_member_path(cast_member, show_id: show)
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

      it "deletes the cast member" do
        cast_member = show.cast_members.create!(valid_attributes)
        delete show_cast_member_path(cast_member, show_id: show)
        expect(CastMember.count).to eq 0
      end

      it "renders no content" do
        cast_member = show.cast_members.create!(valid_attributes)
        delete show_cast_member_path(cast_member, show_id: show)
        expect(response).to be_no_content
      end
    end
  end

  describe "POST /shows/:show_id/cast_members/:id/move" do
    context "when user is not signed in" do
      it "redirects to the user sign in page" do
        cast_member = show.cast_members.create!(valid_attributes)
        post move_show_cast_member_path(cast_member, show_id: show)
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

      it "updates the cast member position" do
        cast_member = show.cast_members.create!(valid_attributes)
        post move_show_cast_member_path(cast_member, show_id: show), params: {position: 2}
        expect(response).to be_successful
        expect(cast_member.reload.position).to eq 2
      end
    end
  end
end
