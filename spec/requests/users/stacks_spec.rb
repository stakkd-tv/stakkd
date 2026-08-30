require "rails_helper"

RSpec.describe "Users::Stacks", type: :request do
  describe "GET /users/:username/stacks" do
    context "when the user is private" do
      it "redirects to the user page" do
        user = FactoryBot.create(:user, private: true)
        get user_stacks_path(user)
        expect(response).to redirect_to(user_path(user))
      end
    end

    context "when the user is private but is the current user" do
      it "renders a success" do
        user = FactoryBot.create(:user, private: true)
        session = Session.new(user:)
        allow(Current).to receive(:session).and_return(session)
        allow(Current).to receive(:user).and_return(user)

        get user_stacks_path(user)
        expect(response).to have_http_status(:success)
      end
    end

    context "when the user is not private" do
      it "renders a success" do
        user = FactoryBot.create(:user, private: false)
        get user_stacks_path(user)
        expect(response).to have_http_status(:success)
      end
    end
  end
end
