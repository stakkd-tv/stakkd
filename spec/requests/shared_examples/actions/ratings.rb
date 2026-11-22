RSpec.shared_examples "a model with rating actions" do
  let(:user) { FactoryBot.create(:user) }

  def rating_action_path(action)
    public_send("#{action}_rating_#{record.route_name}_path", record.records_for_polymorphic_paths)
  end

  def sign_in_for_rating
    allow(Current).to receive(:session).and_return(Session.new(user:))
    allow(Current).to receive(:user).and_return(user)
  end

  describe "PUT /rating" do
    it "requires sign-in" do
      put rating_action_path(:set), params: {score: 8}
      expect(response).to redirect_to(new_session_path)
    end

    it "sets and replaces only the signed-in user's score" do
      sign_in_for_rating
      other = FactoryBot.create(:user)
      other_rating = Rating.create!(user: other, item: record, score: 3)

      put rating_action_path(:set), params: {score: 8, user_id: other.id}, as: :json
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to eq("score" => 8)

      put rating_action_path(:set), params: {score: 10}, as: :json
      expect(response).to have_http_status(:ok)
      expect(user.ratings.where(item: record).pluck(:score)).to eq([10])
      expect(other_rating.reload.score).to eq(3)
    end

    it "returns a structured error for a fractional score" do
      sign_in_for_rating
      put rating_action_path(:set), params: {score: 7.5}, as: :json
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body).to eq("errors" => ["Score must be a whole number from 1 to 10"])
      expect(user.ratings).to be_empty
    end
  end

  describe "DELETE /rating" do
    it "requires sign-in" do
      delete rating_action_path(:remove)
      expect(response).to redirect_to(new_session_path)
    end

    it "removes only the signed-in user's rating and succeeds on retry" do
      sign_in_for_rating
      Rating.create!(user:, item: record, score: 8)
      other_rating = Rating.create!(user: FactoryBot.create(:user), item: record, score: 3)

      2.times do
        delete rating_action_path(:remove)
        expect(response).to have_http_status(:ok)
        expect(response.parsed_body).to eq("score" => nil)
      end

      expect(user.ratings).to be_empty
      expect(other_rating.reload.score).to eq(3)
    end
  end
end
