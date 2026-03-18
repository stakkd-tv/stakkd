# frozen_string_literal: true

require "rails_helper"

RSpec.describe PasswordsMailer, type: :mailer do
  describe "#reset" do
    it "sends an email to the users email address" do
      user = instance_double(User, username: "user007", email_address: "user@example.com", password_reset_token: "token")
      email = PasswordsMailer.reset(user)
      assert_emails 1 do
        email.deliver_now
      end

      assert_equal ["from@example.com"], email.from
      assert_equal ["user@example.com"], email.to
      assert_equal "Reset your Stakkd password", email.subject
      expect(email.body.parts.last.body).to include(edit_password_url("token"))
      expect(email.body.parts.last.body).to include("Hi user007!")
    end
  end
end
