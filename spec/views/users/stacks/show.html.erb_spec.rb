require "rails_helper"

RSpec.describe "users/stacks/show.html.erb", type: :view do
  let(:posters) { [] }
  let(:backgrounds) { [] }
  let(:logos) { [] }

  before(:each) do
    def view.authenticated? = false
    def view.current_user = nil
    @user = FactoryBot.create(:user)
    @stack = FactoryBot.create(
      :stack,
      name: "Amazing stack",
      description: "This is an amazing stack",
      user: @user
    )
    @movie = FactoryBot.create(:movie, :with_release_date, date_for_release: Date.today, translated_title: "Great Movie")
    FactoryBot.create(:stack_item, stack: @stack, item: @movie)
    @show = FactoryBot.create(:show, :with_premiere_date, date_for_premiere: Date.tomorrow, translated_title: "Great Show")
    FactoryBot.create(:stack_item, stack: @stack, item: @show)
    assign(:stack, @stack)
    assign(:user, @user)
    assign(:stack_items, @stack.stack_items.includes(item: [:show, :season]))
    assign(:watch_statuses, {@movie => :consumed, @show => :not_consumed})
  end

  it "renders attributes" do
    render
    expect(rendered).to match(/Amazing stack/)
    expect(rendered).to match(/This is an amazing stack/)
    expect(rendered).to match(/2 items/)
  end

  it "renders the stack items" do
    render
    assert_select "#stack_items" do
      assert_select "h5", text: "Great Movie"
      assert_select "a[href='#{movie_path(Movie.last)}']", count: 2

      assert_select "h5", text: "Great Show"
      assert_select "a[href='#{show_path(Show.first)}']", count: 2
    end
  end

  it "renders the add to history dialog" do
    render
    assert_select "dialog[data-controller='history-dialog']"
  end

  it "renders the add to stack dialog" do
    render
    assert_select "dialog[data-controller='stack-dialog']"
  end

  it "renders the add to history buttons for each stack item with the correct status when authenticated" do
    allow(view).to receive(:authenticated?).and_return(true)
    render
    assert_select "button[title='Add to history'][data-history-button-add-to-history-url-value='#{add_to_history_movie_path(@movie)}'][data-status='consumed']"
    assert_select "button[title='Add to history'][data-history-button-add-to-history-url-value='#{add_to_history_show_path(@show)}'][data-status='not_consumed']"
  end

  it "renders the add to stack buttons for each stack item when authenticated" do
    allow(view).to receive(:authenticated?).and_return(true)
    render
    assert_select "button[title='Add to stack'][data-stack-button-add-to-stack-url-value='#{add_to_stack_movie_path(@movie)}']"
    assert_select "button[title='Add to stack'][data-stack-button-add-to-stack-url-value='#{add_to_stack_show_path(@show)}']"
  end

  it "does not render the add to stack buttons when not authenticated" do
    allow(view).to receive(:authenticated?).and_return(false)
    render
    assert_select "button[title='Add to stack'][data-stack-button-add-to-stack-url-value='#{add_to_stack_movie_path(@movie)}']", count: 0
    assert_select "button[title='Add to stack'][data-stack-button-add-to-stack-url-value='#{add_to_stack_show_path(@show)}']", count: 0
  end

  it "renders a select box for sorting" do
    render
    assert_select "select#sort" do
      Stack::SORTING_METHODS.each do |method|
        if method == @stack.sorting_method
          assert_select "option[value='#{method}'][selected='selected']", text: method.humanize
        else
          assert_select "option[value='#{method}']", text: method.humanize
        end
      end
    end
  end

  it "renders an icon for sort direction" do
    render
    assert_select "i.fa-arrow-up[data-direction='#{@stack.sorting_direction}']"
  end

  context "when the current user is the creator of the stack" do
    before do
      def view.current_user
        @user
      end
    end

    it "renders a button to destroy the stack items" do
      render
      assert_select "i.fa-xmark", count: 2
    end
  end

  context "when the current user is not the creator of the stack" do
    it "does not render a button to destroy the stack items" do
      render
      assert_select "i.fa-xmark", count: 0
    end
  end
end
