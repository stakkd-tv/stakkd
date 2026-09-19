require "rails_helper"

RSpec.describe "Users::StackItems", type: :request do
  describe "DELETE /users/:username/stacks/:stack_id/stack_items/:id" do
    let(:user) { FactoryBot.create(:user, :confirmed) }
    let(:stack) { FactoryBot.create(:stack, user:) }
    let(:stack_item) { FactoryBot.create(:stack_item, stack:) }

    def perform(format: :html)
      delete user_stack_stack_item_path(user, stack, stack_item, format:)
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

      it "does not delete the stack item" do
        perform
        expect(StackItem.count).to eq(1)
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

      it "does not delete the stack item" do
        perform
        expect(StackItem.count).to eq(1)
      end
    end

    context "when the stack belongs to the current user" do
      before do
        session = Session.new(user:)
        allow(Current).to receive(:session).and_return(session)
        allow(Current).to receive(:user).and_return(user)
      end

      context "when the stack item does not belong to the stack" do
        let(:other_stack) { FactoryBot.create(:stack, user:) }
        let(:stack_item) { FactoryBot.create(:stack_item, stack: other_stack) }

        it "does not delete the stack item" do
          perform
          expect(StackItem.count).to eq(1)
        end

        it "renders a 404" do
          perform
          expect(response).to have_http_status(:not_found)
        end
      end

      context "when the request is HTML" do
        it "deletes the stack item" do
          perform
          expect(StackItem.count).to eq(0)
        end

        it "redirects to the user stack page" do
          perform
          expect(response).to redirect_to user_stack_path(user, stack)
        end
      end

      context "when the request is JSON" do
        it "deletes the stack" do
          perform(format: :json)
          expect(StackItem.count).to eq(0)
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
