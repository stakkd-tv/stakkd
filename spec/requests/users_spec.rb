require "rails_helper"

RSpec.describe "Users", type: :request do
  describe "GET /users/new" do
    it "returns http success" do
      get "/users/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /users" do
    context "with valid params" do
      it "redirects to root path" do
        post users_path, params: {user: {username: "hey", email_address: "hey@hey.com", password: "hey", password_confirmation: "hey"}}
        expect(response).to redirect_to root_path
        expect(flash[:notice]).to eq "Success! You'll need to confirm your email before logging in."
      end

      it "creates an unconfirmed user with a confirmation token" do
        post users_path, params: {user: {username: "hey", email_address: "hey@hey.com", password: "hey", password_confirmation: "hey"}}
        user = User.last
        expect(user.email_address).to eq "hey@hey.com"
        expect(user.username).to eq "hey"
        expect(user.confirmed?).to be false
        expect(user.confirmation_tokens.count).to eq 1
      end

      it "sends a confirmation email" do
        mail = instance_double(ActionMailer::MessageDelivery)
        expect(ConfirmationsMailer).to receive(:confirm).and_return(mail)
        expect(mail).to receive(:deliver_later)
        post users_path, params: {user: {username: "hey", email_address: "hey@hey.com", password: "hey", password_confirmation: "hey"}}
      end
    end

    context "with invalid params" do
      it "renders a 422" do
        post users_path, params: {user: {username: nil, email_address: nil, password: nil, password_confirmation: nil}}
        expect(response.status).to eq 422
      end

      it "does not create a user" do
        post users_path, params: {user: {username: nil, email_address: nil, password: nil, password_confirmation: nil}}
        expect(User.count).to eq 0
        expect(ConfirmationToken.count).to eq 0
      end

      it "does not send an email" do
        expect(ConfirmationsMailer).not_to receive(:confirm)
        post users_path, params: {user: {username: nil, email_address: nil, password: nil, password_confirmation: nil}}
      end
    end
  end

  describe "GET /users/confirm" do
    context "when user is logged in" do
      before do
        @user = FactoryBot.create(:user)
        session = @user.sessions.create!(user_agent: "Mozilla/", ip_address: "192.168.0.1")
        allow(Current).to receive(:session).and_return(session)
        allow(Current).to receive(:user).and_return(@user)
      end

      it "terminates the users seassion" do
        get confirm_users_path
        expect(@user.reload.sessions.count).to eq 0
        expect(cookies[:session_id]).not_to be_present
      end
    end

    context "when there is a token found" do
      it "confirms the user and deletes the token" do
        user = FactoryBot.create(:user, confirmed_at: nil)
        token = ConfirmationToken.create!(user: user)
        get confirm_users_path, params: {token: token.token}
        expect(user.reload.confirmed_at).to be_present
        expect(ConfirmationToken.count).to eq 0
      end

      it "redirects to the login page with a notice" do
        user = FactoryBot.create(:user, confirmed_at: nil)
        token = ConfirmationToken.create!(user: user)
        get confirm_users_path, params: {token: token.token}
        expect(response).to redirect_to(new_session_path)
        expect(flash[:notice]).to eq "Successfully confirmed your account, you can now login!"
      end

      context "when the user is already confirmed" do
        it "does not re-confirm the user" do
          confirmed_at = DateTime.new(2023, 1, 1, 10)
          user = FactoryBot.create(:user, confirmed_at:)
          token = ConfirmationToken.create!(user: user)
          get confirm_users_path, params: {token: token.token}
          expect(user.reload.confirmed_at).to eq confirmed_at
          expect(ConfirmationToken.count).to eq 1
        end

        it "redirects to the root path with an alert" do
          user = FactoryBot.create(:user, :confirmed)
          token = ConfirmationToken.create!(user: user)
          get confirm_users_path, params: {token: token.token}
          expect(response).to redirect_to(root_path)
          expect(flash[:alert]).to eq "Confirmation link is invalid or has expired. Please request a new confirmation email."
        end
      end
    end

    context "when no token is found" do
      it "does not confirm the user" do
        user = FactoryBot.create(:user, confirmed_at: nil)
        token = ConfirmationToken.create!(user: user)
        token.update(expires_at: Time.current - 1.minute)
        get confirm_users_path, params: {token: token.token}
        expect(user.reload.confirmed_at).not_to be_present
        expect(ConfirmationToken.count).to eq 1
      end

      it "redirects to the root path with an alert" do
        user = FactoryBot.create(:user, confirmed_at: nil)
        token = ConfirmationToken.create!(user: user)
        token.update(expires_at: Time.current - 1.minute)
        get confirm_users_path, params: {token: token.token}
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq "Confirmation link is invalid or has expired. Please request a new confirmation email."
      end
    end
  end
end
