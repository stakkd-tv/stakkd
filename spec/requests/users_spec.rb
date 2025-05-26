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

      it "creates a user" do
        post users_path, params: {user: {username: "hey", email_address: "hey@hey.com", password: "hey", password_confirmation: "hey"}}
        user = User.last
        expect(user.email_address).to eq "hey@hey.com"
        expect(user.username).to eq "hey"
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
      end
    end
  end
end
