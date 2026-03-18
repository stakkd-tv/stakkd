require "rails_helper"

RSpec.describe "Passwords", type: :request do
  describe "GET /passwords/new" do
    it "returns http success" do
      get new_password_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /passwords" do
    context "when user is found" do
      it "enqueues a password reset email" do
        user = FactoryBot.create(:user, :confirmed, email_address: "user@example.com")
        mailer = instance_double(ActionMailer::MessageDelivery)
        expect(PasswordsMailer).to receive(:reset).with(user).and_return(mailer)
        expect(mailer).to receive(:deliver_later)
        post passwords_path, params: {email_address: "user@example.com"}
      end

      it "redirects with a notice" do
        FactoryBot.create(:user, :confirmed, email_address: "user@example.com")
        post passwords_path, params: {email_address: "user@example.com"}
        expect(response).to redirect_to(new_session_path)
        expect(flash[:notice]).to eq "Password reset instructions sent (if a confirmed user account with that email address exists)."
      end
    end

    context "when user is found but not confirmed" do
      it "enqueues a password reset email" do
        FactoryBot.create(:user, email_address: "user@example.com")
        instance_double(ActionMailer::MessageDelivery)
        expect(PasswordsMailer).not_to receive(:reset)
        post passwords_path, params: {email_address: "user@example.com"}
      end

      it "redirects with a notice" do
        FactoryBot.create(:user, email_address: "user@example.com")
        post passwords_path, params: {email_address: "user@example.com"}
        expect(response).to redirect_to(new_session_path)
        expect(flash[:notice]).to eq "Password reset instructions sent (if a confirmed user account with that email address exists)."
      end
    end

    context "when user is not found" do
      it "does not enqueue a password reset email" do
        expect(PasswordsMailer).not_to receive(:reset)
        post passwords_path, params: {email_address: "user@example.com"}
      end

      it "redirects with a notice" do
        post passwords_path, params: {email_address: "user@example.com"}
        expect(response).to redirect_to(new_session_path)
        expect(flash[:notice]).to eq "Password reset instructions sent (if a confirmed user account with that email address exists)."
      end
    end
  end

  describe "GET /passwords/:token/edit" do
    let(:user) { FactoryBot.create(:user, :confirmed) }
    let(:token) { user.password_reset_token }

    context "when token is valid" do
      it "renders http success" do
        get edit_password_path(token: token)
        expect(response).to have_http_status(:success)
      end
    end

    context "when token is valid, but user is not confirmed" do
      let(:user) { FactoryBot.create(:user) }

      it "redirects to the new password page with a flash alert" do
        get edit_password_path(token: token)
        expect(response).to redirect_to(new_password_path)
        expect(flash[:alert]).to eq "Password reset link is invalid or has expired. Please request a new password reset link."
      end
    end

    context "when token is invalid" do
      let(:token) { "bogus" }

      it "redirects to the new password page with a flash alert" do
        get edit_password_path(token: token)
        expect(response).to redirect_to(new_password_path)
        expect(flash[:alert]).to eq "Password reset link is invalid or has expired. Please request a new password reset link."
      end
    end
  end

  describe "PUT /passwords/:token" do
    let(:user) { FactoryBot.create(:user, :confirmed) }
    let(:token) { user.password_reset_token }

    context "when token is valid" do
      context "when password confirmation matches" do
        it "updates the password and redirects to the sign in page with a flash notice" do
          expect {
            put password_path(token: token), params: {password: "newpassword", password_confirmation: "newpassword"}
          }.to change { user.reload.password_digest }
          expect(response).to redirect_to(new_session_path)
          expect(flash[:notice]).to eq "Password has been reset. You can now sign in."
        end
      end

      context "when password confirmation does not match" do
        it "does not update the users password and redirects with a flash alert" do
          expect {
            put password_path(token: token), params: {password: "newpassword1", password_confirmation: "newpassword2"}
          }.not_to change { user.reload.password_digest }
          expect(response).to redirect_to(edit_password_path(token))
          expect(flash[:alert]).to eq "Passwords did not match. Please try again."
        end
      end
    end

    context "when token is valid, but user is not confirmed" do
      let(:user) { FactoryBot.create(:user) }

      it "redirects to the new password page with a flash alert" do
        expect {
          put password_path(token: token), params: {password: "newpassword", password_confirmation: "newpassword"}
        }.not_to change { user.reload.password_digest }
        expect(response).to redirect_to(new_password_path)
        expect(flash[:alert]).to eq "Password reset link is invalid or has expired. Please request a new password reset link."
      end
    end

    context "when token is invalid" do
      let(:token) { "bogus" }

      it "redirects to the new password page with a flash alert" do
        put password_path(token: token)
        expect(response).to redirect_to(new_password_path)
        expect(flash[:alert]).to eq "Password reset link is invalid or has expired. Please request a new password reset link."
      end
    end
  end
end
