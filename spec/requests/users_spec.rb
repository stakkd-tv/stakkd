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

      it "displays a private profile" do
        user = FactoryBot.create(:user, username: "private_user", private: true, biography: "This my bio")
        FactoryBot.create(:stack, user: user)
        FactoryBot.create(:history_item, user: user)

        get user_path(user)
        expect(response).to have_http_status(:success)
        assert_select "h1", text: "private_user"
        assert_select "h4", text: "This user's profile is private. You won't be able to see their activity unless they accept your follow request."
        assert_select "div[data-markdown-renderer-markdown-value='This my bio']", count: 0
        assert_select "h4.text-xl", text: "Recently watched:", count: 0
        assert_select "h4.text-xl", text: "Stacks:", count: 0
      end
    end

    context "when the user is private and is the current logged in user" do
      before do
        @current_user = FactoryBot.create(:user, username: "testing123", private: true, biography: "This my bio")
        session = @current_user.sessions.create!(user_agent: "Mozilla/", ip_address: "192.168.0.1")
        allow(Current).to receive(:session).and_return(session)
        allow(Current).to receive(:user).and_return(@current_user)

        FactoryBot.create(:stack, user: @current_user)
        FactoryBot.create(:history_item, user: @current_user)
      end

      it "displays the public profile" do
        get user_path(@current_user)
        expect(response).to have_http_status(:success)
        assert_select "h1", text: "testing123"
        assert_select "h4", text: "This user's profile is private. You won't be able to see their activity unless they accept your follow request.", count: 0
        assert_select "div[data-markdown-renderer-markdown-value='This my bio']"
        assert_select "h4.text-xl", text: "Recently watched:"
        assert_select "h4.text-xl", text: "Stacks:"
      end
    end

    context "when the user is not private" do
      it "displays the public profile for the user" do
        user = FactoryBot.create(:user, username: "normal_user", biography: "This my bio")
        FactoryBot.create(:stack, user: user)
        FactoryBot.create(:history_item, user: user)

        get user_path(user)
        expect(response).to have_http_status(:success)
        assert_select "h1", text: "normal_user"
        assert_select "h4", text: "This user's profile is private. You won't be able to see their activity unless they accept your follow request.", count: 0
        assert_select "div[data-markdown-renderer-markdown-value='This my bio']"
        assert_select "h4.text-xl", text: "Recently watched:"
        assert_select "h4.text-xl", text: "Stacks:"
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

  describe "GET /users/:id/watchlist" do
    let(:user) { FactoryBot.create(:user, private: user_private) }
    let(:watchlist) { user.watchlist }
    let(:current_user) { nil }

    let(:sort) { nil }
    let(:direction) { nil }
    let(:filters) { nil }

    before do
      if current_user
        session = Session.new(user: current_user)
        allow(Current).to receive(:session).and_return(session)
        allow(Current).to receive(:user).and_return(current_user)
      end
    end

    def perform
      get watchlist_user_path(user, sort:, direction:, filters:)
    end

    shared_examples_for "user watchlist show page" do
      it "renders a successful response" do
        perform
        expect(response).to be_successful
      end

      context "when there are filters" do
        context "with invalid filter" do
          let(:filters) { ["invalid"] }

          it "does not try to filter with the invalid value" do
            stack_items = instance_double("Association", count: 0)
            allow_any_instance_of(Stack).to receive(:stack_items).and_return(stack_items)
            allow(stack_items).to receive(:where).with(item_type: []).and_return(stack_items)
            ordered = instance_double("Association")
            expect(stack_items).to receive(:ordered_by_position).and_return(ordered)
            expect(ordered).to receive(:includes).and_return([])
            perform
          end
        end

        context "with valid filter" do
          let(:filters) { ["Movie"] }

          it "filters by the media type" do
            stack_items = instance_double("Association", count: 0)
            allow_any_instance_of(Stack).to receive(:stack_items).and_return(stack_items)
            allow(stack_items).to receive(:where).with(item_type: ["Movie"]).and_return(stack_items)
            ordered = instance_double("Association")
            expect(stack_items).to receive(:ordered_by_position).and_return(ordered)
            expect(ordered).to receive(:includes).and_return([])
            perform
          end
        end
      end

      context "when there is a sort param" do
        context "when the param is valid" do
          let(:sort) { "position" }

          it "sets the sort to the param" do
            stack_items = instance_double("Association", count: 0)
            allow_any_instance_of(Stack).to receive(:stack_items).and_return(stack_items)
            allow(stack_items).to receive(:where).and_return(stack_items)
            ordered = instance_double("Association")
            expect(stack_items).to receive(:ordered_by_position).and_return(ordered)
            expect(ordered).to receive(:includes).and_return([])
            perform
            assert_select "select#sort" do
              assert_select "option[selected][value='position']"
            end
          end
        end

        context "when the param is not valid" do
          let(:sort) { "invalid" }

          it "sets the sort to the default" do
            stack_items = instance_double("Association", count: 0)
            allow_any_instance_of(Stack).to receive(:stack_items).and_return(stack_items)
            allow(stack_items).to receive(:where).and_return(stack_items)
            ordered = instance_double("Association")
            expect(stack_items).to receive(:ordered_by_position).and_return(ordered)
            expect(ordered).to receive(:includes).and_return([])
            perform
            assert_select "select#sort" do
              assert_select "option[selected][value='position']"
            end
          end
        end
      end

      context "when there is a direction param" do
        context "when the param is valid" do
          let(:direction) { "desc" }

          it "sets the sort to the param" do
            stack_items = instance_double("Association", count: 0)
            allow_any_instance_of(Stack).to receive(:stack_items).and_return(stack_items)
            allow(stack_items).to receive(:where).and_return(stack_items)
            ordered = instance_double("Association")
            expect(stack_items).to receive(:ordered_by_position).with(:desc).and_return(ordered)
            expect(ordered).to receive(:includes).and_return([])
            perform
            assert_select "i[data-direction='desc']"
          end
        end

        context "when the param is not valid" do
          let(:direction) { "invalid" }

          it "sets the sort to the default" do
            stack_items = instance_double("Association", count: 0)
            allow_any_instance_of(Stack).to receive(:stack_items).and_return(stack_items)
            allow(stack_items).to receive(:where).and_return(stack_items)
            ordered = instance_double("Association")
            expect(stack_items).to receive(:ordered_by_position).with(:asc).and_return(ordered)
            expect(ordered).to receive(:includes).and_return([])
            perform
            assert_select "i[data-direction='asc']"
          end
        end
      end
    end

    context "when the watchlist is public" do
      let(:current_user) { nil }
      let(:user_private) { false }

      before do
        watchlist.update(private: false)
      end

      it_behaves_like "user watchlist show page"
    end

    context "when the watchlist is private" do
      let(:current_user) { nil }
      let(:user_private) { false }

      before do
        watchlist.update(private: true)
      end

      it "redirects to the user page with a flash message" do
        perform
        expect(response).to redirect_to(user_path(user))
        expect(flash[:alert]).to eq("This user's watchlist is private.")
      end
    end

    context "when the watchlist is not marked as private but the user is" do
      let(:current_user) { nil }
      let(:user_private) { true }

      before do
        watchlist.update(private: false)
      end

      it "redirects to the user page" do
        perform
        expect(response).to redirect_to(user_path(user))
      end
    end

    context "when the watchlist is private but is created by the current user" do
      let(:current_user) { user }
      let(:user_private) { false }

      before do
        watchlist.update(private: true)
      end

      it_behaves_like "user watchlist show page"
    end

    context "when the watchlist is created by the current user, who is private" do
      let(:current_user) { user }
      let(:user_private) { true }

      before do
        watchlist.update(private: false)
      end

      it_behaves_like "user watchlist show page"
    end
  end
end
