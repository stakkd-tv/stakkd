require "rails_helper"

RSpec.describe StackItemPresenter, type: :presenter do
  let(:presenter) { described_class.new(stack_item) }
  let(:stack_item) { FactoryBot.create(:stack_item, added_at: DateTime.new(2026, 10, 20, 10), item:) }
  let(:item) { FactoryBot.create(:movie, runtime: 60) }

  describe "#sorting_detail" do
    subject { presenter.sorting_detail(sorting_method) }

    context "when sorting method is not valid" do
      let(:sorting_method) { "hello darkness my old friend" }

      it { should be_nil }
    end

    context "when sorting method is added_at" do
      let(:sorting_method) { "added_at" }

      it { should eq "Added: Oct 20, 2026 10:00" }
    end

    context "when sorting method is position" do
      let(:sorting_method) { "position" }

      it { should eq "Position #<span class='stackItem-position'>1</span>" }
    end

    context "when sorting method is release_date" do
      let(:sorting_method) { "release_date" }

      context "when release date is nil" do
        it { should eq "Release: TBA" }
      end

      context "when release date is not nil" do
        let(:item) { FactoryBot.create(:movie, :with_release_date, date_for_release: DateTime.new(2026, 10, 20, 10), runtime: 60) }

        it { should eq "Release: October 20, 2026" }
      end
    end

    context "when sorting method is runtime" do
      let(:sorting_method) { "runtime" }

      it { should eq "Runtime: 1h 0m" }
    end
  end
end
