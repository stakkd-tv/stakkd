RSpec.shared_examples "a model with history actions" do
  include ActiveSupport::Testing::TimeHelpers

  describe "POST /add_to_history" do
    let(:params) { {consumed_at_type:, consumed_at:} }
    let(:consumed_at) { nil }
    let(:logged_in) { true }

    before do
      travel_to Time.current

      if logged_in
        user = FactoryBot.create(:user)
        session = Session.new(user:)
        allow(Current).to receive(:session).and_return(session)
        allow(Current).to receive(:user).and_return(user)
      end
    end

    context "when user is not signed in" do
      let(:logged_in) { false }
      let(:consumed_at_type) { "now" }

      it "redirects to the sign in page" do
        perform
        expect(response).to redirect_to new_session_path
      end
    end

    context "when consumed at type is 'now'" do
      let(:consumed_at) { nil }
      let(:consumed_at_type) { "now" }

      context "when consumed at is present" do
        let(:consumed_at) { DateTime.new(2026, 2, 2, 10) }

        it "ignores the consumed at and sets to current time" do
          expect_any_instance_of(Manage::History).to receive(:add!)
            .with(record.items_for_history, consumed_at: Time.current)
          perform
        end
      end

      it "adds to history at the current time" do
        expect_any_instance_of(Manage::History).to receive(:add!)
          .with(record.items_for_history, consumed_at: Time.current)
        perform
      end

      it "renders json with a success code" do
        perform
        json = JSON.parse(response.body)
        expect(json).to eq({"success" => true})
        expect(response).to be_successful
      end
    end

    context "when consumed at type is 'release_date'" do
      let(:consumed_at) { nil }
      let(:consumed_at_type) { "release_date" }

      context "when consumed at is present" do
        let(:consumed_at) { DateTime.new(2026, 2, 2, 10) }

        it "ignores the consumed at and sets to release date" do
          expect_any_instance_of(Manage::History).to receive(:add!)
            .with(record.items_for_history, consumed_at: :release_date)
          perform
        end
      end

      it "adds to history at the release date" do
        expect_any_instance_of(Manage::History).to receive(:add!)
          .with(record.items_for_history, consumed_at: :release_date)
        perform
      end

      it "renders json with a success code" do
        perform
        json = JSON.parse(response.body)
        expect(json).to eq({"success" => true})
        expect(response).to be_successful
      end
    end

    context "when consumed at type is 'date'" do
      let(:consumed_at) { DateTime.new(2026, 3, 3, 10) }
      let(:consumed_at_type) { "date" }

      it "adds to history at the date given" do
        expect_any_instance_of(Manage::History).to receive(:add!)
          .with(record.items_for_history, consumed_at:)
        perform
      end

      it "renders json with a success code" do
        perform
        json = JSON.parse(response.body)
        expect(json).to eq({"success" => true})
        expect(response).to be_successful
      end
    end

    context "when consumed at type is 'unknown'" do
      let(:consumed_at) { nil }
      let(:consumed_at_type) { "unknown" }

      context "when consumed at is present" do
        let(:consumed_at) { DateTime.new(2026, 2, 2, 10) }

        it "ignores the consumed at and sets unknown" do
          expect_any_instance_of(Manage::History).to receive(:add!)
            .with(record.items_for_history, consumed_at: nil)
          perform
        end
      end

      it "adds to history at an unknown time" do
        expect_any_instance_of(Manage::History).to receive(:add!)
          .with(record.items_for_history, consumed_at: nil)
        perform
      end

      it "renders json with a success code" do
        perform
        json = JSON.parse(response.body)
        expect(json).to eq({"success" => true})
        expect(response).to be_successful
      end
    end

    context "when consumed at type is invalid" do
      let(:consumed_at_type) { nil }

      it "does not add anything to history" do
        expect(Manage::History).not_to receive(:new)
        perform
      end

      it "renders json with a 422 status" do
        perform
        json = JSON.parse(response.body)
        expect(json).to eq({"success" => false, "errors" => ["Could not add #{record.class.to_s.downcase} to history"]})
        expect(response.status).to eq 422
      end
    end
  end
end
