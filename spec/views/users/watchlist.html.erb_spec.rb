require "rails_helper"

RSpec.describe "users/watchlist.html.erb", type: :view do
  before(:each) do
    def view.authenticated? = false
    def view.current_user = nil
    allow(view).to receive(:params).and_return({controller: "users", action: "watchlist"})
    @user = FactoryBot.create(:user)
    @stack = @user.watchlist
    @movie = FactoryBot.create(:movie, :with_release_date, date_for_release: Date.today, translated_title: "Great Movie", runtime: 25)
    FactoryBot.create(:stack_item, stack: @stack, item: @movie)
    @show = FactoryBot.create(:show, :with_premiere_date, date_for_premiere: Date.tomorrow, translated_title: "Great Show")
    FactoryBot.create(:stack_item, stack: @stack, item: @show)
    assign(:stack, @stack)
    assign(:user, @user)
    assign(:stack_items, @stack.stack_items.includes(item: [:show, :season]).map { StackItemPresenter.new(it) })
    assign(:watch_statuses, {@movie => :consumed, @show => :not_consumed})
    assign(:sorting_method, @stack.sorting_method)
    assign(:sorting_direction, @stack.sorting_direction)
    assign(:filter_options, Stack::ALLOWED_ITEM_TYPES.map { [it.pluralize, it] })
    assign(:selected_filters, [])
    assign(:reorderable, false)
    assign(:watchlisted_items, [])
  end

  it "renders the sorting detail" do
    render
    assert_select "small", text: "Position #1"
  end

  it "renders nav links" do
    render
    assert_select "a[data-active='false']", text: "Profile"
    assert_select "a[data-active='false']", text: "History"
    assert_select "a[data-active='false']", text: "Progress"
    assert_select "a[data-active='true']", text: "Watchlist"
    assert_select "a[data-active='false']", text: "Collection"
    assert_select "a[data-active='false']", text: "Ratings"
    assert_select "a[data-active='false']", text: "Stacks"
    assert_select "a[data-active='false']", text: "Comments"
    assert_select "a[data-active='false']", text: "Followers"
    assert_select "a[data-active='false']", text: "Following"
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
    assert_select "form[action='#{watchlist_user_path(@user)}'][data-controller='stack-controls']" do
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
  end

  it "renders an icon for sort direction" do
    render
    assert_select "form[action='#{watchlist_user_path(@user)}'][data-controller='stack-controls']" do
      assert_select "i.fa-arrow-up[data-direction='#{@stack.sorting_direction}']"
    end
  end

  it "renders a multi select box for filtering" do
    render
    assert_select "form[action='#{watchlist_user_path(@user)}'][data-controller='stack-controls']" do
      assert_select "select#filters" do
        Stack::ALLOWED_ITEM_TYPES.each do |filter|
          assert_select "option[value='#{filter}']", text: filter.pluralize
        end
      end
    end
  end

  context "when the current user is the creator of the stack" do
    before do
      def view.current_user
        @user
      end
    end

    it "renders a button to destroy the stack items" do
      render
      assert_select "button[data-controller='deletion-button'][data-deletion-button-delete-record-url-value='#{user_stack_stack_item_path(@user, @stack, StackItem.first)}']"
      assert_select "button[data-controller='deletion-button'][data-deletion-button-delete-record-url-value='#{user_stack_stack_item_path(@user, @stack, StackItem.second)}']"
    end

    it "renders a button to edit the stack" do
      render
      assert_select "button[data-controller='edit-stack-button']"
    end

    it "renders a disabled button to reorder the stack when cannot reorder" do
      assign(:reorderable, false)
      render
      assert_select "button[data-stack-controls-target='reorderingButton'][disabled]"
    end

    it "renders a button to reorder the stack when can reorder" do
      assign(:reorderable, true)
      render
      assert_select "button[data-stack-controls-target='reorderingButton'][disabled]", count: 0
      assert_select "button[data-stack-controls-target='reorderingButton']"
    end

    it "renders a hidden drag handle for each stack item" do
      render
      assert_select "i.drag-handle.hidden\\!", count: 2
    end
  end

  context "when the current user is not the creator of the stack" do
    it "does not render a button to destroy the stack items" do
      render
      assert_select "button[data-controller='deletion-button'][data-deletion-button-delete-record-url-value='#{user_stack_stack_item_path(@user, @stack, StackItem.first)}']", count: 0
      assert_select "button[data-controller='deletion-button'][data-deletion-button-delete-record-url-value='#{user_stack_stack_item_path(@user, @stack, StackItem.second)}']", count: 0
    end

    it "does not render a button to edit the stack" do
      render
      assert_select "button[data-controller='edit-stack-button']", count: 0
    end

    it "does not render a button to reorder the stack" do
      render
      assert_select "button[data-stack-controls-target='reorderingButton']", count: 0
    end

    it "does not render any drag handles for the stack items" do
      render
      assert_select "i.drag-handle.hidden\\!", count: 0
    end
  end
end
