# frozen_string_literal: true

require "rails_helper"

RSpec.describe ConfirmationsMailer, type: :mailer do
  describe "#confirm" do
    it "sends an email to the users email address" do
      user = instance_double(User, username: "user007", email_address: "user@example.com", password_reset_token: "token")
      token = instance_double(ConfirmationToken, token: "token", user: user)
      email = ConfirmationsMailer.confirm(token)
      assert_emails 1 do
        email.deliver_now
      end

      assert_equal ["from@example.com"], email.from
      assert_equal ["user@example.com"], email.to
      assert_equal "Confirm your Stakkd account", email.subject
      expect(email.body.parts.last.body).to include(confirm_users_url(token: "token"))
      expect(email.body.parts.last.body).to include("Hi user007!")
    end
  end

  describe "#reminder" do
    it "sends an email to the users email address" do
      user = instance_double(User, username: "user007", email_address: "user@example.com", password_reset_token: "token")
      token = instance_double(ConfirmationToken, token: "token", user: user)
      email = ConfirmationsMailer.reminder(user, token)
      assert_emails 1 do
        email.deliver_now
      end

      assert_equal ["from@example.com"], email.from
      assert_equal ["user@example.com"], email.to
      assert_equal "Your Stakkd account is scheduled for deletion", email.subject
      expect(email.body.parts.last.body).to include(confirm_users_url(token: "token"))
      expect(email.body.parts.last.body).to include(new_confirmation_token_url)
      expect(email.body.parts.last.body).to include("Hi user007,")
    end
  end
end
