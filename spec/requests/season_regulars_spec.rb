require "rails_helper"

RSpec.describe "SeasonRegulars", type: :request do
  let(:season) { FactoryBot.create(:season) }
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

  describe "GET /shows/:show_id/seasons/:season_id/season_regulars" do
    context "when user is not signed in" do
      it "redirects to the user sign in page" do
        get show_season_season_regulars_path(season, show_id: season.show)
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
        get show_season_season_regulars_path(season, show_id: season.show)
        expect(response).to be_successful
      end
    end
  end

  describe "POST /shows/:show_id/seasons/:season_id/season_regulars" do
    context "when user is not signed in" do
      it "redirects to the user sign in page" do
        post show_season_season_regulars_path(season, show_id: season.show), params: {cast_member: valid_attributes}
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

      context "when cast member is already a recurring season regular" do
        before do
          FactoryBot.create(:cast_member, record: season.show, person: person)
        end

        it "does not add a cast member and redirects to the index page" do
          post show_season_season_regulars_path(season, show_id: season.show), params: {cast_member: valid_attributes}
          expect(CastMember.count).to eq 1
          expect(response).to redirect_to show_season_season_regulars_path(season, show_id: season.show)
          expect(flash[:alert]).to eq "That cast member has already been assigned as a recurring season regular to this show."
        end
      end

      context "with valid params" do
        it "creates a cast member" do
          post show_season_season_regulars_path(season, show_id: season.show), params: {cast_member: valid_attributes}
          cast_member = CastMember.last
          expect(cast_member.record).to eq season
          expect(cast_member.person).to eq person
          expect(cast_member.character).to eq "Test character"
        end

        it "redirects to the cast members index path" do
          post show_season_season_regulars_path(season, show_id: season.show), params: {cast_member: valid_attributes}
          expect(response).to redirect_to show_season_season_regulars_path(season, show_id: season.show)
        end

        context "when add_to_all_seasons is true" do
          it "adds the cast member to the show instead of the season" do
            post show_season_season_regulars_path(season, show_id: season.show), params: {cast_member: valid_attributes, add_to_all_seasons: true}
            cast_member = CastMember.last
            expect(cast_member.record).to eq season.show
            expect(cast_member.person).to eq person
            expect(cast_member.character).to eq "Test character"
          end
        end
      end

      context "with invalid params" do
        it "does not create an cast member" do
          post show_season_season_regulars_path(season, show_id: season.show), params: {cast_member: invalid_attributes}
          expect(CastMember.count).to eq 0
        end

        it "redirects to the cast members index path with a flash alert" do
          post show_season_season_regulars_path(season, show_id: season.show), params: {cast_member: invalid_attributes}
          expect(response).to redirect_to show_season_season_regulars_path(season, show_id: season.show)
          expect(flash[:alert]).to eq "Could not add that cast member."
        end
      end
    end
  end

  describe "PATCH /shows/:show_id/seasons/:season_id/season_regulars/:id" do
    let(:new_person) { FactoryBot.create(:person) }
    let(:new_attributes) {
      {
        person_id: new_person.id,
        character: "New character"
      }
    }

    context "when user is not signed in" do
      it "redirects to the user sign in page" do
        cast_member = season.season_regulars.create!(valid_attributes)
        patch show_season_season_regular_path(cast_member, season_id: season, show_id: season.show), params: {cast_member: new_attributes}
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
          cast_member = season.season_regulars.create!(valid_attributes)
          patch show_season_season_regular_path(cast_member, season_id: season, show_id: season.show), params: {cast_member: new_attributes}
          cast_member.reload
          expect(cast_member.person).to eq new_person
          expect(cast_member.character).to eq "New character"
        end

        it "renders json" do
          cast_member = season.season_regulars.create!(valid_attributes)
          patch show_season_season_regular_path(cast_member, season_id: season, show_id: season.show), params: {cast_member: new_attributes}
          expect(response).to be_successful
          json = JSON.parse(response.body)
          expect(json).to eq({
            "success" => true
          })
        end
      end

      context "with invalid params" do
        it "does not update the cast member" do
          cast_member = season.season_regulars.create!(valid_attributes)
          patch show_season_season_regular_path(cast_member, season_id: season, show_id: season.show), params: {cast_member: invalid_attributes}
          cast_member.reload
          expect(cast_member.person).to eq person
          expect(cast_member.character).to eq "Test character"
        end

        it "renders json with errors" do
          cast_member = season.season_regulars.create!(valid_attributes)
          patch show_season_season_regular_path(cast_member, season_id: season, show_id: season.show), params: {cast_member: invalid_attributes}
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

  describe "DELETE /shows/:show_id/seasons/:season_id/season_regulars/:id" do
    context "when user is not signed in" do
      it "redirects to the user sign in page" do
        cast_member = season.season_regulars.create!(valid_attributes)
        delete show_season_season_regular_path(cast_member, season_id: season, show_id: season.show)
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
        cast_member = season.season_regulars.create!(valid_attributes)
        delete show_season_season_regular_path(cast_member, season_id: season, show_id: season.show)
        expect(CastMember.count).to eq 0
      end

      it "renders no content" do
        cast_member = season.season_regulars.create!(valid_attributes)
        delete show_season_season_regular_path(cast_member, season_id: season, show_id: season.show)
        expect(response).to be_no_content
      end
    end
  end

  describe "POST /shows/:show_id/seasons/:season_id/season_regulars/:id/move" do
    context "when user is not signed in" do
      it "redirects to the user sign in page" do
        cast_member = season.season_regulars.create!(valid_attributes)
        post move_show_season_season_regular_path(cast_member, season_id: season, show_id: season.show)
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
        cast_member = season.season_regulars.create!(valid_attributes)
        post move_show_season_season_regular_path(cast_member, season_id: season, show_id: season.show), params: {position: 2}
        expect(response).to be_successful
        expect(cast_member.reload.position).to eq 2
      end
    end
  end
end
