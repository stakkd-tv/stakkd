RSpec.shared_examples_for "a model that can be added to history" do
  describe "#history_manager_for" do
    it "returns a history manager for the given user" do
      user = User.new
      history = record.history_manager_for(user)
      expect(history).to be_a(Manage::History)
      expect(history.user).to eq user
    end
  end

  describe "#add_to_history!" do
    it "adds to the given users history" do
      user = User.new
      history = Manage::History.new(user)
      allow(Manage::History).to receive(:new).with(user).and_return(history)
      expect(history).to receive(:add!).with(record, consumed_at: nil)
      record.add_to_history!(user, consumed_at: nil)
    end
  end

  describe "#remove_all_from_history" do
    it "removes all items from the history" do
      user = User.new
      history = Manage::History.new(user)
      allow(Manage::History).to receive(:new).with(user).and_return(history)
      expect(history).to receive(:remove_all).with(record)
      record.remove_all_from_history(user)
    end
  end

  describe "#status_for" do
    it "retrieves the status" do
      user = User.new
      history = Manage::History.new(user)
      allow(Manage::History).to receive(:new).with(user).and_return(history)
      expect(history).to receive(:status_for).with(record)
      record.status_for(user)
    end
  end

  describe "#items_for_history" do
    it "returns the items that need to be added to history" do
      expect(record.items_for_history).to eq items_for_history
    end
  end

  describe "#history_release_date" do
    it "returns the items release date" do
      if release_date == :raises
        expect { record.history_release_date }.to raise_error(NotImplementedError)
      else
        expect(record.history_release_date).not_to be_nil
        expect(record.history_release_date).to eq release_date
      end
    end
  end
end
