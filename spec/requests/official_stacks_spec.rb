require 'rails_helper'

RSpec.describe "Official Stacks", type: :request do
  describe "GET /stacks/official/:id" do
    let(:stack) { FactoryBot.create(:stack, user:, sorting_method: "added_at", sorting_direction: "asc") }
    let(:user) { nil }

    let(:sort) { nil }
    let(:direction) { nil }
    let(:filters) { nil }

    def perform
      get official_stack_path(stack, sort:, direction:, filters:)
    end

    shared_examples_for "official stack show page" do
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
            expect(stack_items).to receive(:ordered_by_added_at).and_return(ordered)
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
            expect(stack_items).to receive(:ordered_by_added_at).and_return(ordered)
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
            expect(stack_items).to receive(:ordered_by_added_at).and_return(ordered)
            expect(ordered).to receive(:includes).and_return([])
            perform
            assert_select "select#sort" do
              assert_select "option[selected][value='added_at']"
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
            expect(stack_items).to receive(:ordered_by_added_at).with(:desc).and_return(ordered)
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
            expect(stack_items).to receive(:ordered_by_added_at).with(:asc).and_return(ordered)
            expect(ordered).to receive(:includes).and_return([])
            perform
            assert_select "i[data-direction='asc']"
          end
        end
      end
    end

    context "when the stack is public" do
      it_behaves_like "official stack show page"
    end

    context "when the stack is not official" do
      let(:user) { FactoryBot.create(:user) }

      it "renders a 404" do
        perform
        expect(response.status).to eq 404
      end
    end
  end
end
