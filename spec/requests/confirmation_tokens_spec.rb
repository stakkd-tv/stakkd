require "rails_helper"

RSpec.describe "ConfirmationTokens", type: :request do
  describe "GET /confirmations/new" do
    it "returns http success" do
      get new_confirmation_token_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /confirmations" do
    context "when no user is found" do
      it "does not send a confirmation email" do
        expect(ConfirmationsMailer).not_to receive(:confirm)
        post confirmation_tokens_path, params: {email_address: "user@example.com"}
      end

      it "redirects to the login page with notice" do
        post confirmation_tokens_path, params: {email_address: "user@example.com"}
        expect(response).to redirect_to(new_session_path)
        expect(flash[:notice]).to eq("A confirmation email has been resent to your email (if a user was found with that email address).")
      end
    end

    context "when user is found" do
      context "when user is already confirmed" do
        it "does not send a confirmation email" do
          expect(ConfirmationsMailer).not_to receive(:confirm)
          FactoryBot.create(:user, :confirmed, email_address: "user@example.com")
          post confirmation_tokens_path, params: {email_address: "user@example.com"}
        end

        it "redirects to the login page with notice" do
          FactoryBot.create(:user, :confirmed, email_address: "user@example.com")
          post confirmation_tokens_path, params: {email_address: "user@example.com"}
          expect(response).to redirect_to(new_session_path)
          expect(flash[:notice]).to eq("A confirmation email has been resent to your email (if a user was found with that email address).")
        end
      end

      context "when user is not confirmed" do
        context "when there is already an active token" do
          it "sends a confirmation email with the existing token" do
            user = FactoryBot.create(:user, email_address: "user@example.com")
            token = user.confirmation_tokens.create
            mail = instance_double(ActionMailer::MessageDelivery)
            expect(ConfirmationsMailer).to receive(:confirm).with(token).and_return(mail)
            expect(mail).to receive(:deliver_later)
            post confirmation_tokens_path, params: {email_address: "user@example.com"}
          end

          it "redirects to the login page with notice" do
            user = FactoryBot.create(:user, email_address: "user@example.com")
            user.confirmation_tokens.create
            post confirmation_tokens_path, params: {email_address: "user@example.com"}
            expect(response).to redirect_to(new_session_path)
            expect(flash[:notice]).to eq("A confirmation email has been resent to your email (if a user was found with that email address).")
          end
        end

        context "when there is no active token" do
          it "creates a token and sends a confirmation email" do
            user = FactoryBot.create(:user, email_address: "user@example.com")
            mail = instance_double(ActionMailer::MessageDelivery)
            expect(ConfirmationsMailer).to receive(:confirm).and_return(mail)
            expect(mail).to receive(:deliver_later)
            post confirmation_tokens_path, params: {email_address: "user@example.com"}
            expect(user.confirmation_tokens.count).to eq(1)
          end

          it "redirects to the login page with notice" do
            user = FactoryBot.create(:user, email_address: "user@example.com")
            post confirmation_tokens_path, params: {email_address: "user@example.com"}
            expect(user.confirmation_tokens.count).to eq(1)
            expect(response).to redirect_to(new_session_path)
            expect(flash[:notice]).to eq("A confirmation email has been resent to your email (if a user was found with that email address).")
          end
        end
      end
    end
  end
end
