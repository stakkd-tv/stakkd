require "rails_helper"

RSpec.describe "Session", type: :request do
  describe "GET /session/new" do
    it "returns http success" do
      get new_session_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /session" do
    context "when user is found" do
      it "starts a new session for the user" do
        user = FactoryBot.create(:user, :confirmed, email_address: "user@example.com", password: "123456")
        post session_path, params: {email_address: "user@example.com", password: "123456"}
        expect(user.sessions.count).to eq 1
        expect(cookies[:session_id]).to be_present
      end

      it "redirects with a notice" do
        FactoryBot.create(:user, :confirmed, email_address: "user@example.com", password: "123456")
        post session_path, params: {email_address: "user@example.com", password: "123456"}
        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to eq "Successfully logged in. Enjoy your stay!"
      end
    end

    context "when user is found but not confirmed" do
      it "does not sign in any user" do
        user = FactoryBot.create(:user, email_address: "user@example.com", password: "123456")
        post session_path, params: {email_address: "user@example.com", password: "123456"}
        expect(user.sessions.count).to eq 0
        expect(cookies[:session_id]).not_to be_present
      end

      it "renders 422" do
        FactoryBot.create(:user, email_address: "user@example.com", password: "123456")
        post session_path, params: {email_address: "user@example.com", password: "1234566"}
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context "when user is found but confirmed and banned" do
      it "does not sign in any user" do
        user = FactoryBot.create(:user, :confirmed, banned_at: Time.current, ban_reason: "Test", email_address: "user@example.com", password: "123456")
        post session_path, params: {email_address: "user@example.com", password: "123456"}
        expect(user.sessions.count).to eq 0
        expect(cookies[:session_id]).not_to be_present
      end

      it "renders 422" do
        FactoryBot.create(:user, :confirmed, banned_at: Time.current, ban_reason: "Test", email_address: "user@example.com", password: "123456")
        post session_path, params: {email_address: "user@example.com", password: "1234566"}
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context "when user is not found" do
      it "does not sign in any user" do
        user = FactoryBot.create(:user, email_address: "user@example.com", password: "123456")
        post session_path, params: {email_address: "user@example.com", password: "1234567"}
        expect(user.sessions.count).to eq 0
        expect(cookies[:session_id]).not_to be_present
      end

      it "renders 422" do
        post session_path, params: {email_address: "user@example.com", password: "1234567"}
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "DELETE /session" do
    context "when user is logged in" do
      before do
        @user = FactoryBot.create(:user)
        session = @user.sessions.create!(user_agent: "Mozilla/", ip_address: "192.168.0.1")
        allow(Current).to receive(:session).and_return(session)
        allow(Current).to receive(:user).and_return(@user)
      end

      it "terminates the users seassion" do
        delete session_path
        expect(@user.reload.sessions.count).to eq 0
        expect(cookies[:session_id]).not_to be_present
      end

      it "redirects with a notice" do
        delete session_path
        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to eq "Successfully logged out. Come back soon!"
      end
    end

    context "when user is not logged in" do
      it "redirects to the login page" do
        delete session_path
        expect(response).to redirect_to(new_session_path)
      end
    end
  end
end
