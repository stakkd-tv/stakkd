require "rails_helper"

RSpec.describe "Movies CrewMembers", type: :request do
  let(:movie) { FactoryBot.create(:movie) }
  let(:person) { FactoryBot.create(:person) }
  let(:job) { FactoryBot.create(:job) }
  let(:valid_attributes) {
    {
      person_id: person.id,
      job_id: job.id
    }
  }

  let(:invalid_attributes) {
    valid_attributes.merge({
      person_id: nil,
      job_id: nil
    })
  }

  describe "GET /movies/:movie_id/crew_members" do
    context "when user is not signed in" do
      it "redirects to the user sign in page" do
        get movie_crew_members_path(movie_id: movie)
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
        get movie_crew_members_path(movie_id: movie)
        expect(response).to be_successful
      end
    end
  end

  describe "POST /movies/:movie_id/crew_members" do
    context "when user is not signed in" do
      it "redirects to the user sign in page" do
        post movie_crew_members_path(movie_id: movie), params: {crew_member: valid_attributes}
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
        it "creates an crew member" do
          post movie_crew_members_path(movie_id: movie), params: {crew_member: valid_attributes}
          crew_member = CrewMember.last
          expect(crew_member.record).to eq movie
          expect(crew_member.person).to eq person
          expect(crew_member.job).to eq job
        end

        it "redirects to the crew members index path" do
          post movie_crew_members_path(movie_id: movie), params: {crew_member: valid_attributes}
          expect(response).to redirect_to movie_crew_members_path(movie_id: movie)
        end
      end

      context "with invalid params" do
        it "does not create an crew member" do
          post movie_crew_members_path(movie_id: movie), params: {crew_member: invalid_attributes}
          expect(CrewMember.count).to eq 0
        end

        it "redirects to the crew members index path with a flash alert" do
          post movie_crew_members_path(movie_id: movie), params: {crew_member: invalid_attributes}
          expect(response).to redirect_to movie_crew_members_path(movie_id: movie)
          expect(flash[:alert]).to eq "Could not add that crew member."
        end
      end
    end
  end

  describe "PATCH /movies/:movie_id/crew_members/:id" do
    let(:new_person) { FactoryBot.create(:person) }
    let(:new_job) { FactoryBot.create(:job) }
    let(:new_attributes) {
      {
        person_id: new_person.id,
        job_id: new_job.id
      }
    }

    context "when user is not signed in" do
      it "redirects to the user sign in page" do
        crew_member = movie.crew_members.create!(valid_attributes)
        patch movie_crew_member_path(crew_member, movie_id: movie), params: {crew_member: new_attributes}
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
        it "updates the crew member" do
          crew_member = movie.crew_members.create!(valid_attributes)
          patch movie_crew_member_path(crew_member, movie_id: movie), params: {crew_member: new_attributes}
          crew_member.reload
          expect(crew_member.person).to eq new_person
          expect(crew_member.job).to eq new_job
        end

        it "renders json" do
          crew_member = movie.crew_members.create!(valid_attributes)
          patch movie_crew_member_path(crew_member, movie_id: movie), params: {crew_member: new_attributes}
          expect(response).to be_successful
          json = JSON.parse(response.body)
          expect(json).to eq({
            "success" => true
          })
        end
      end

      context "with invalid params" do
        it "does not update the crew member" do
          crew_member = movie.crew_members.create!(valid_attributes)
          patch movie_crew_member_path(crew_member, movie_id: movie), params: {crew_member: invalid_attributes}
          crew_member.reload
          expect(crew_member.person).to eq person
          expect(crew_member.job).to eq job
        end

        it "renders json with errors" do
          crew_member = movie.crew_members.create!(valid_attributes)
          patch movie_crew_member_path(crew_member, movie_id: movie), params: {crew_member: invalid_attributes}
          expect(response.status).to eq 422
          json = JSON.parse(response.body)
          expect(json).to eq({
            "success" => false,
            "errors" => [
              {"person" => ["Person must exist"]},
              {"job" => ["Job must exist"]}
            ]
          })
        end
      end
    end
  end

  describe "DELETE /movies/:movie_id/crew_members/:id" do
    context "when user is not signed in" do
      it "redirects to the user sign in page" do
        crew_member = movie.crew_members.create!(valid_attributes)
        delete movie_crew_member_path(crew_member, movie_id: movie)
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

      it "deletes the crew member" do
        crew_member = movie.crew_members.create!(valid_attributes)
        delete movie_crew_member_path(crew_member, movie_id: movie)
        expect(CrewMember.count).to eq 0
      end

      it "renders no content" do
        crew_member = movie.crew_members.create!(valid_attributes)
        delete movie_crew_member_path(crew_member, movie_id: movie)
        expect(response).to be_no_content
      end
    end
  end
end
