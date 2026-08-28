RSpec.shared_examples "stackable actions" do
  include ActiveSupport::Testing::TimeHelpers

  let(:user) { FactoryBot.create(:user) }

  describe "POST /add_to_stack" do
    let(:stack) { FactoryBot.create(:stack, user:) }
    let(:stack_id) { stack.id }

    context "when a user is not signed in" do
      it "redirects to the sign in page" do
        perform_add_to_stack
        expect(response).to redirect_to new_session_path
      end
    end

    context "when a user is signed in" do
      before do
        session = Session.new(user:)
        allow(Current).to receive(:session).and_return(session)
        allow(Current).to receive(:user).and_return(user)
      end

      context "when the given stack does not exist" do
        let(:stack) { FactoryBot.create(:stack) } # For a different user

        it "renders json with an error and 404 status" do
          perform_add_to_stack
          expect(response).to have_http_status(:not_found)
          json = JSON.parse(response.body)
          expect(json).to eq({"success" => false, "errors" => ["Stack not found"]})
        end
      end

      context "when the stack exists" do
        it "adds the item to the stack" do
          perform_add_to_stack
          expect(stack.reload.stack_items.count).to eq 1
        end

        it "renders json" do
          perform_add_to_stack
          expect(response).to have_http_status(:ok)
          json = JSON.parse(response.body)
          expect(json).to eq({"success" => true, "stacks_for_this_record" => [stack.id]})
        end

        context "when the item is already in the stack" do
          it "renders json with an error message and 422 status" do
            StackItem.create!(stack:, item:, added_at: Time.current)
            perform_add_to_stack
            expect(response).to have_http_status(:unprocessable_content)
            json = JSON.parse(response.body)
            expect(json).to eq({"success" => false, "errors" => ["Failed to add to stack"]})
          end
        end
      end
    end
  end

  describe "POST /create_and_add_to_stack" do
    context "when a user is not signed in" do
      let(:stack_name) { "Testing" }

      it "redirects to the sign in page" do
        perform_create_and_add_to_stack
        expect(response).to redirect_to new_session_path
      end
    end

    context "when a user is signed in" do
      before do
        session = Session.new(user:)
        allow(Current).to receive(:session).and_return(session)
        allow(Current).to receive(:user).and_return(user)
      end

      context "without a name for the stack" do
        let(:stack_name) { nil }

        it "renders json error with 422 status" do
          perform_create_and_add_to_stack
          expect(response).to have_http_status(:unprocessable_content)
          json = JSON.parse(response.body)
          expect(json).to eq({"success" => false, "errors" => ["Could not create stack"]})
        end
      end

      context "with a name for the stack" do
        let(:stack_name) { "Amazing stack" }

        it "creates the stack and adds the item to it" do
          perform_create_and_add_to_stack
          stack = Stack.includes(stack_items: :item).last
          expect(stack.name).to eq(stack_name)
          expect(stack.stack_items.count).to eq 1
          expect(stack.stack_items.first.item).to eq item
        end

        it "renders json with a success status" do
          perform_create_and_add_to_stack
          expect(response).to have_http_status(:ok)
          json = JSON.parse(response.body)
          expect(json).to eq({"success" => true, "stack" => {"id" => Stack.last.id, "name" => stack_name}, "stacks_for_this_record" => [Stack.last.id]})
        end
      end
    end
  end

  describe "DELETE /remove_from_stack" do
    let(:stack) { FactoryBot.create(:stack, user:) }
    let(:stack_id) { stack.id }

    context "when a user is not signed in" do
      it "redirects to the sign in page" do
        perform_remove_from_stack
        expect(response).to redirect_to new_session_path
      end
    end

    context "when a user is signed in" do
      before do
        session = Session.new(user:)
        allow(Current).to receive(:session).and_return(session)
        allow(Current).to receive(:user).and_return(user)
      end

      context "when the given stack does not exist" do
        let(:stack) { FactoryBot.create(:stack) } # For a different user

        it "renders json with an error and 404 status" do
          perform_remove_from_stack
          expect(response).to have_http_status(:not_found)
          json = JSON.parse(response.body)
          expect(json).to eq({"success" => false, "errors" => ["Stack not found"]})
        end
      end

      context "when the stack exists" do
        it "removes the item to the stack" do
          StackItem.create!(stack:, item:, added_at: Time.current)
          perform_remove_from_stack
          expect(stack.reload.stack_items.count).to eq 0
          expect(StackItem.count).to eq 0
        end

        it "renders json" do
          StackItem.create!(stack:, item:, added_at: Time.current)
          perform_remove_from_stack
          expect(response).to have_http_status(:ok)
          json = JSON.parse(response.body)
          expect(json).to eq({"success" => true, "stacks_for_this_record" => []})
        end

        context "when the item is not in the stack" do
          it "renders json with an error message and 422 status" do
            perform_remove_from_stack
            expect(response).to have_http_status(:unprocessable_content)
            json = JSON.parse(response.body)
            expect(json).to eq({"success" => false, "errors" => ["Failed to remove from stack"]})
          end
        end
      end
    end
  end

  describe "GET /load-more-top-stacks" do
    context "when request is html" do
      it "renders a 404" do
        perform_load_more_top_stacks(format: :html)
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when request is turbo_stream" do
      it "renders a successful response" do
        perform_load_more_top_stacks(format: :turbo_stream)
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
