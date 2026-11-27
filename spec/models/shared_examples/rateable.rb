RSpec.shared_examples "a rateable model" do
  describe "associations" do
    it { should have_many(:ratings).dependent(:delete_all) }
  end

  describe ".with_rating_summary" do
    it "constrains the ratings scan to each selected item" do
      # A range prevents a constant primary-key lookup from masking a global aggregate.
      relation = described_class.with_rating_summary.where(id: 1..).limit(1)
      plan = JSON.parse(described_class.connection.select_value("EXPLAIN (FORMAT JSON) #{relation.to_sql}"))
      nodes = []
      visit = ->(node) {
        nodes << node
        node.fetch("Plans", []).each { |child| visit.call(child) }
      }
      visit.call(plan.first.fetch("Plan"))
      rating_scans = nodes.select { |node| node["Relation Name"] == "ratings" }

      expect(rating_scans).not_to be_empty
      rating_scans.each do |scan|
        conditions = scan.values_at("Index Cond", "Recheck Cond", "Filter").compact.join(" ")
        expect(conditions).to include("item_id = #{described_class.table_name}.id")
      end
    end

    it "returns the direct average at full precision, including private accounts" do
      [7, 8, 10].each do |score|
        FactoryBot.create(:rating, item:, score:, user: FactoryBot.create(:user, private: score == 10))
      end

      summary = described_class.with_rating_summary.find(item.id)
      expect(summary.average_rating).to be_within(0.000001).of(BigDecimal(25) / 3)
      expect(summary.ratings_count).to eq(3)
    end

    it "retains unrated items with no average and zero votes" do
      summary = described_class.with_rating_summary.find(item.id)
      expect(summary.average_rating).to be_nil
      expect(summary.ratings_count).to eq(0)
    end

    it "reflects replacements and removal of the last vote on subsequent queries" do
      rating = FactoryBot.create(:rating, item:, score: 8)
      rating.update!(score: 6)
      summary = described_class.with_rating_summary.find(item.id)
      expect(summary.average_rating).to eq(6)
      expect(summary.ratings_count).to eq(1)

      rating.destroy!
      summary = described_class.with_rating_summary.find(item.id)
      expect(summary.average_rating).to be_nil
      expect(summary.ratings_count).to eq(0)
    end

    it "retrieves summaries for a batch in one query without loading individual votes" do
      items = FactoryBot.create_list(described_class.model_name.singular, 3)
      items.each { |item| FactoryBot.create(:rating, item:) }
      queries = []
      track_query = ->(_name, _start, _finish, _id, payload) {
        queries << payload[:sql] if payload[:sql].start_with?("SELECT")
      }

      summaries = ActiveSupport::Notifications.subscribed(track_query, "sql.active_record") do
        described_class.with_rating_summary.where(id: items.map(&:id)).to_a
      end

      expect(queries.size).to eq(1)
      expect(summaries.map(&:average_rating)).to eq([8, 8, 8])
      expect(summaries.map(&:ratings_count)).to eq([1, 1, 1])
      expect(summaries).to all(satisfy { |item| !item.association(:ratings).loaded? })
    end
  end
end
