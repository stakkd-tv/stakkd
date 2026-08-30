require "rails_helper"

module Stacks
  RSpec.describe WithPreviews do
    let(:instance) { WithPreviews.new(stacks, user: current_user, per_page: 3) }
    let(:user) { FactoryBot.create(:user) }
    let(:stacks) { user.stacks }
    let(:current_user) { nil }

    describe "#fetch" do
      context "when no user is passed to with_previews" do
        let(:current_user) { nil }

        before do
          # A stack for this user that is not part of results as outside of 3 per page limit
          FactoryBot.create(:stack, user:)
          # A stack for this user that is private so not included in results
          FactoryBot.create(:stack, user:, private: true)
          # A stack for this user
          @stack2 = FactoryBot.create(:stack, user:)
          # A non-standard stack for this user
          FactoryBot.create(:stack, user:, type: "watchlist")
          # A stack for this user with more than three stack items
          @stack3 = FactoryBot.create(:stack, user:)
          FactoryBot.create(:stack_item, stack: @stack3)
          FactoryBot.create(:stack_item, stack: @stack3)
          FactoryBot.create(:stack_item, stack: @stack3)
          FactoryBot.create(:stack_item, stack: @stack3)
          # A stack for this user
          @stack4 = FactoryBot.create(:stack, user:)
          # A stack that this not for this user
          FactoryBot.create(:stack)
        end

        it "returns a hash with only three stacks as keys without including any private stacks" do
          result = instance.fetch.first
          expect(result.keys).to contain_exactly(@stack2, @stack3, @stack4)
        end

        it "returns only three stack items per stack" do
          result = instance.fetch.first
          stack3_results = result[@stack3]
          expect(stack3_results.count).to eq 3
        end

        it "returns an empty hash when there are no stacks" do
          stacks.destroy_all
          result = instance.fetch.first
          expect(result).to eq({})
        end

        it "includes the next page" do
          next_page = instance.fetch.last
          expect(next_page).to eq 2
        end
      end

      context "when the current_user is present" do
        let(:current_user) { user }

        before do
          @stack1 = FactoryBot.create(:stack, user:, private: true)
          # Private, but not for this user
          FactoryBot.create(:stack, private: true)
        end

        it "returns the stacks including the users own private stacks" do
          result = instance.fetch.first
          expect(result.keys).to contain_exactly(@stack1)
        end
      end
    end
  end
end
