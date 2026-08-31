require "rails_helper"

RSpec.describe "Users::Stacks", type: :request do
  let(:valid_attributes) {
    {
      name: "Test Stack",
      description: "This is a description",
      private: true
    }
  }

  let(:invalid_attributes) {
    valid_attributes.merge({
      name: nil
    })
  }

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

      it "calls for stacks with previews" do
        user = FactoryBot.create(:user, private: false)
        with_previews = instance_double(Stacks::WithPreviews)
        expect(Stacks::WithPreviews).to receive(:new).and_return(with_previews)
        expect(with_previews).to receive(:fetch).with(page: "2").and_return([{}, nil])
        get user_stacks_path(user, page: 2)
      end

      it "renders HTML when requested with Turbo Accept headers without page param" do
        user = FactoryBot.create(:user, private: false)
        get user_stacks_path(user), headers: {"Accept" => "text/vnd.turbo-stream.html, text/html, application/xhtml+xml"}
        expect(response).to have_http_status(:success)
        expect(response.content_type).to include("text/html")
      end

      it "renders turbo_stream when requested with page param and turbo_stream Accept header" do
        user = FactoryBot.create(:user, private: false)
        get user_stacks_path(user, page: 2), headers: {"Accept" => "text/vnd.turbo-stream.html"}
        expect(response).to have_http_status(:success)
        expect(response.content_type).to include("text/vnd.turbo-stream.html")
      end
    end
  end

  describe "GET /users/:username/stacks/new" do
    let(:user) { FactoryBot.create(:user, :confirmed) }

    context "when current user is not the same as the user being viewed" do
      it "redirects" do
        user = FactoryBot.create(:user)
        get new_user_stack_path(user)
        expect(response).to redirect_to(user_path(user))
      end
    end

    context "when the user is the same as the user being viewed" do
      it "renders a successful response" do
        user = FactoryBot.create(:user)
        session = Session.new(user:)
        allow(Current).to receive(:session).and_return(session)
        allow(Current).to receive(:user).and_return(user)

        get new_user_stack_path(user)
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "POST /users/:username/stacks" do
    context "when the user is the same as the user for the stack" do
      before do
        @user = FactoryBot.create(:user)
        session = Session.new(user: @user)
        allow(Current).to receive(:session).and_return(session)
        allow(Current).to receive(:user).and_return(@user)
      end

      context "with valid parameters" do
        it "creates a new Stack" do
          post user_stacks_path(@user), params: {stack: valid_attributes}
          stack = Stack.includes(:user).last
          expect(stack.user).to eq @user
          expect(stack.name).to eq "Test Stack"
          expect(stack.description).to eq "This is a description"
          expect(stack.type).to eq "standard"
          expect(stack.sorting_method).to eq "added_at"
          expect(stack.private).to eq true
        end

        it "redirects to the stacks page" do
          post user_stacks_path(@user), params: {stack: valid_attributes}
          expect(response).to redirect_to(user_stacks_path(@user))
        end
      end

      context "with invalid parameters" do
        it "does not create a new stack" do
          expect {
            post user_stacks_path(@user), params: {stack: invalid_attributes}
          }.to change(Stack, :count).by(0)
        end

        it "renders a response with 422 status (i.e. to display the 'new' template)" do
          post user_stacks_path(@user), params: {stack: invalid_attributes}
          expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end

    context "when the user is not the same as the user for this stack" do
      it "redirects" do
        user = FactoryBot.create(:user)
        post user_stacks_path(user), params: {stack: valid_attributes}
        expect(response).to redirect_to user_path(user)
      end
    end
  end

  describe "DELETE /users/:username/stacks/:id" do
    let(:user) { FactoryBot.create(:user, :confirmed) }
    let(:stack) { FactoryBot.create(:stack, user:) }

    def perform(format: :html)
      delete user_stack_path(user, stack, format:)
    end

    context "when the user is not the current logged in user" do
      before do
        another_user = FactoryBot.create(:user)
        session = Session.new(user: another_user)
        allow(Current).to receive(:session).and_return(session)
        allow(Current).to receive(:user).and_return(another_user)
      end

      it "redirects to the user page" do
        perform
        expect(response).to redirect_to user_path(user)
      end

      it "does not delete the stack" do
        perform
        expect(Stack.count).to eq(1)
      end
    end

    context "when the stack does not belong to the current user" do
      let(:stack) { FactoryBot.create(:stack) }

      before do
        session = Session.new(user:)
        allow(Current).to receive(:session).and_return(session)
        allow(Current).to receive(:user).and_return(user)
      end

      it "renders a 404" do
        perform
        expect(response).to have_http_status(:not_found)
      end

      it "does not delete the stack" do
        perform
        expect(Stack.count).to eq(1)
      end
    end

    context "when the stack belongs to the current user" do
      before do
        session = Session.new(user:)
        allow(Current).to receive(:session).and_return(session)
        allow(Current).to receive(:user).and_return(user)
      end

      context "when the request is HTML" do
        it "deletes the stack" do
          perform
          expect(Stack.count).to eq(0)
        end

        it "redirects to the user stacks page" do
          perform
          expect(response).to redirect_to user_stacks_path(user)
        end
      end

      context "when the request is JSON" do
        it "deletes the stack" do
          perform(format: :json)
          expect(Stack.count).to eq(0)
        end

        it "renders json" do
          perform(format: :json)
          expect(response).to have_http_status(:ok)
          json = JSON.parse(response.body)
          expect(json).to eq({"success" => true})
        end
      end
    end
  end
end
