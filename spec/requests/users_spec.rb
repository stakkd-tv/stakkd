require "rails_helper"

RSpec.describe "Users", type: :request do
  describe "GET /users/new" do
    it "returns http success" do
      get "/users/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /users/:id" do
    context "when the username is me" do
      context "when no user is logged in" do
        it "renders a 404" do
          get user_path("me")
          expect(response).to have_http_status(:not_found)
        end
      end

      context "when a user is logged in" do
        before do
          @user = FactoryBot.create(:user, username: "testing123")
          session = @user.sessions.create!(user_agent: "Mozilla/", ip_address: "192.168.0.1")
          allow(Current).to receive(:session).and_return(session)
          allow(Current).to receive(:user).and_return(@user)
        end

        it "displays the profile for the current user" do
          get user_path("me")
          expect(response).to have_http_status(:success)
          assert_select "h1", text: "testing123"
        end
      end
    end

    context "when the user is private and is not the current logged in user" do
      before do
        @current_user = FactoryBot.create(:user, username: "testing123")
        session = @current_user.sessions.create!(user_agent: "Mozilla/", ip_address: "192.168.0.1")
        allow(Current).to receive(:session).and_return(session)
        allow(Current).to receive(:user).and_return(@current_user)
      end

      it "redirects with a flash alert" do
        user = FactoryBot.create(:user, username: "private_user", private: true)
        get user_path(user)
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq "You are not authorized to view this profile."
      end
    end

    context "when the user is private and is the current logged in user" do
      before do
        @current_user = FactoryBot.create(:user, username: "testing123", private: true)
        session = @current_user.sessions.create!(user_agent: "Mozilla/", ip_address: "192.168.0.1")
        allow(Current).to receive(:session).and_return(session)
        allow(Current).to receive(:user).and_return(@current_user)
      end

      it "displays the profile" do
        get user_path(@current_user)
        expect(response).to have_http_status(:success)
        assert_select "h1", text: "testing123"
      end
    end

    context "when the user is not private" do
      it "displays the profile for the user" do
        user = FactoryBot.create(:user, username: "normal_user")
        get user_path(user)
        expect(response).to have_http_status(:success)
        assert_select "h1", text: "normal_user"
      end
    end
  end

  describe "POST /users" do
    context "when the specified trivia is not found" do
      it "renders 422 with an alert" do
        post users_path, params: {user: {username: "hey", email_address: "hey@hey.com", password: "hey", password_confirmation: "hey"}, trivia_question_name: "nonsense"}
        expect(response.status).to eq 422
        expect(flash[:alert]).to eq "Bot accounts are not allowed."
      end
    end

    context "when the trivia answer is not correct" do
      it "renders 422 with an alert" do
        post users_path, params: {user: {username: "hey", email_address: "hey@hey.com", password: "hey", password_confirmation: "hey"}, trivia_question_name: "hulk", trivia_answer: "purple"}
        expect(response.status).to eq 422
        expect(flash[:alert]).to eq "Bot accounts are not allowed."
      end
    end

    context "with valid params" do
      it "redirects to root path" do
        post users_path, params: {user: {username: "hey", email_address: "hey@hey.com", password: "hey", password_confirmation: "hey"}, trivia_question_name: "hulk", trivia_answer: "green"}
        expect(response).to redirect_to root_path
        expect(flash[:notice]).to eq "Success! You'll need to confirm your email before logging in."
      end

      it "creates an unconfirmed user with a confirmation token" do
        post users_path, params: {user: {username: "hey", email_address: "hey@hey.com", password: "hey", password_confirmation: "hey"}, trivia_question_name: "hulk", trivia_answer: "green"}
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
        post users_path, params: {user: {username: "hey", email_address: "hey@hey.com", password: "hey", password_confirmation: "hey"}, trivia_question_name: "hulk", trivia_answer: "green"}
      end
    end

    context "with invalid params" do
      it "renders a 422" do
        post users_path, params: {user: {username: nil, email_address: nil, password: nil, password_confirmation: nil}, trivia_question_name: "hulk", trivia_answer: "green"}
        expect(response.status).to eq 422
      end

      it "does not create a user" do
        post users_path, params: {user: {username: nil, email_address: nil, password: nil, password_confirmation: nil}, trivia_question_name: "hulk", trivia_answer: "green"}
        expect(User.count).to eq 0
        expect(ConfirmationToken.count).to eq 0
      end

      it "does not send an email" do
        expect(ConfirmationsMailer).not_to receive(:confirm)
        post users_path, params: {user: {username: nil, email_address: nil, password: nil, password_confirmation: nil}, trivia_question_name: "hulk", trivia_answer: "green"}
      end
    end
  end

  describe "GET /users/settings" do
    context "when user is logged in" do
      before do
        @user = FactoryBot.create(:user)
        session = @user.sessions.create!(user_agent: "Mozilla/", ip_address: "192.168.0.1")
        allow(Current).to receive(:session).and_return(session)
        allow(Current).to receive(:user).and_return(@user)
      end

      it "returns a success response" do
        get user_settings_path
        expect(response).to be_successful
      end
    end

    context "when user is not logged in" do
      it "redirects to the login page" do
        get user_settings_path
        expect(response).to redirect_to(new_session_path)
      end
    end
  end

  describe "PATCH /users/:id" do
    let(:user) { FactoryBot.create(:user) }
    let(:attributes) {
      {
        profile_picture: Rack::Test::UploadedFile.new(File.join(Rails.root, "spec", "support", "assets", "300x450.png")),
        background: Rack::Test::UploadedFile.new(File.join(Rails.root, "spec", "support", "assets", "300x450.png")),
        biography: "Testing",
        private: true
      }
    }

    context "when the user is not logged in" do
      it "redirects to the login page" do
        patch user_path(user), params: {user: attributes}
        expect(response).to redirect_to(new_session_path)
      end
    end

    context "when the given user is not the current logged in user" do
      before do
        @user = FactoryBot.create(:user)
        session = @user.sessions.create!(user_agent: "Mozilla/", ip_address: "192.168.0.1")
        allow(Current).to receive(:session).and_return(session)
        allow(Current).to receive(:user).and_return(@user)
      end

      it "redirects to the root path with a flash alert" do
        patch user_path(user), params: {user: attributes}
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("You are not authorized to perform this action.")
      end
    end

    context "with valid params" do
      before do
        session = user.sessions.create!(user_agent: "Mozilla/", ip_address: "192.168.0.1")
        allow(Current).to receive(:session).and_return(session)
        allow(Current).to receive(:user).and_return(user)
      end

      it "redirects to the settings path with a flash notice" do
        patch user_path(user), params: {user: attributes}
        expect(response).to redirect_to(user_settings_path)
        expect(flash[:notice]).to eq("Settings updated successfully.")
      end

      it "updates the user" do
        patch user_path(user), params: {user: attributes}
        user.reload
        expect(user.biography).to eq "Testing"
        expect(user.private).to eq true
        expect(user.profile_picture).to be_attached
        expect(user.background).to be_attached
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
          expect(response).to redirect_to(new_confirmation_token_path)
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
        expect(response).to redirect_to(new_confirmation_token_path)
        expect(flash[:alert]).to eq "Confirmation link is invalid or has expired. Please request a new confirmation email."
      end
    end
  end
end
