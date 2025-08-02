require "rails_helper"

RSpec.describe "Movies CastMembers", type: :request do
  let(:movie) { FactoryBot.create(:movie) }
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

  describe "GET /movies/:movie_id/cast_members" do
    context "when user is not signed in" do
      it "redirects to the user sign in page" do
        get movie_cast_members_path(movie_id: movie)
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
        get movie_cast_members_path(movie_id: movie)
        expect(response).to be_successful
      end
    end
  end

  describe "POST /movies/:movie_id/cast_members" do
    context "when user is not signed in" do
      it "redirects to the user sign in page" do
        post movie_cast_members_path(movie_id: movie), params: {cast_member: valid_attributes}
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
          post movie_cast_members_path(movie_id: movie), params: {cast_member: valid_attributes}
          cast_member = CastMember.last
          expect(cast_member.record).to eq movie
          expect(cast_member.person).to eq person
          expect(cast_member.character).to eq "Test character"
        end

        it "redirects to the cast members index path" do
          post movie_cast_members_path(movie_id: movie), params: {cast_member: valid_attributes}
          expect(response).to redirect_to movie_cast_members_path(movie_id: movie)
        end
      end

      context "with invalid params" do
        it "does not create an cast member" do
          post movie_cast_members_path(movie_id: movie), params: {cast_member: invalid_attributes}
          expect(CastMember.count).to eq 0
        end

        it "redirects to the cast members index path with a flash alert" do
          post movie_cast_members_path(movie_id: movie), params: {cast_member: invalid_attributes}
          expect(response).to redirect_to movie_cast_members_path(movie_id: movie)
          expect(flash[:alert]).to eq "Could not add that cast member."
        end
      end
    end
  end

  describe "PATCH /movies/:movie_id/cast_members/:id" do
    let(:new_person) { FactoryBot.create(:person) }
    let(:new_attributes) {
      {
        person_id: new_person.id,
        character: "New character"
      }
    }

    context "when user is not signed in" do
      it "redirects to the user sign in page" do
        cast_member = movie.cast_members.create!(valid_attributes)
        patch movie_cast_member_path(cast_member, movie_id: movie), params: {cast_member: new_attributes}
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
          cast_member = movie.cast_members.create!(valid_attributes)
          patch movie_cast_member_path(cast_member, movie_id: movie), params: {cast_member: new_attributes}
          cast_member.reload
          expect(cast_member.person).to eq new_person
          expect(cast_member.character).to eq "New character"
        end

        it "renders json" do
          cast_member = movie.cast_members.create!(valid_attributes)
          patch movie_cast_member_path(cast_member, movie_id: movie), params: {cast_member: new_attributes}
          expect(response).to be_successful
          json = JSON.parse(response.body)
          expect(json).to eq({
            "success" => true
          })
        end
      end

      context "with invalid params" do
        it "does not update the cast member" do
          cast_member = movie.cast_members.create!(valid_attributes)
          patch movie_cast_member_path(cast_member, movie_id: movie), params: {cast_member: invalid_attributes}
          cast_member.reload
          expect(cast_member.person).to eq person
          expect(cast_member.character).to eq "Test character"
        end

        it "renders json with errors" do
          cast_member = movie.cast_members.create!(valid_attributes)
          patch movie_cast_member_path(cast_member, movie_id: movie), params: {cast_member: invalid_attributes}
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

  describe "DELETE /movies/:movie_id/cast_members/:id" do
    context "when user is not signed in" do
      it "redirects to the user sign in page" do
        cast_member = movie.cast_members.create!(valid_attributes)
        delete movie_cast_member_path(cast_member, movie_id: movie)
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
        cast_member = movie.cast_members.create!(valid_attributes)
        delete movie_cast_member_path(cast_member, movie_id: movie)
        expect(CastMember.count).to eq 0
      end

      it "renders no content" do
        cast_member = movie.cast_members.create!(valid_attributes)
        delete movie_cast_member_path(cast_member, movie_id: movie)
        expect(response).to be_no_content
      end
    end
  end

  describe "POST /movies/:movie_id/cast_members/:id/move" do
    context "when user is not signed in" do
      it "redirects to the user sign in page" do
        cast_member = movie.cast_members.create!(valid_attributes)
        post move_movie_cast_member_path(cast_member, movie_id: movie)
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
        cast_member = movie.cast_members.create!(valid_attributes)
        post move_movie_cast_member_path(cast_member, movie_id: movie), params: {position: 2}
        expect(response).to be_successful
        expect(cast_member.reload.position).to eq 2
      end
    end
  end
end
