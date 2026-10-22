require "rails_helper"

RSpec.describe "official_stacks/show.html.erb", type: :view do
  before(:each) do
    def view.authenticated? = false
    def view.current_user = nil
    @stack = FactoryBot.create(
      :stack,
      name: "Amazing stack",
      description: "This is an amazing stack",
      user: nil,
      sorting_method: "runtime"
    )
    @movie = FactoryBot.create(:movie, :with_release_date, date_for_release: Date.today, translated_title: "Great Movie", runtime: 25)
    FactoryBot.create(:stack_item, stack: @stack, item: @movie)
    @show = FactoryBot.create(:show, :with_premiere_date, date_for_premiere: Date.tomorrow, translated_title: "Great Show")
    FactoryBot.create(:stack_item, stack: @stack, item: @show)
    assign(:stack, @stack)
    assign(:user, nil)
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
    assert_select "small", text: "Runtime: 25m"
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
    assert_select "form[action='#{official_stack_path(@stack)}'][data-controller='stack-controls']" do
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
    assert_select "form[action='#{official_stack_path(@stack)}'][data-controller='stack-controls']" do
      assert_select "i.fa-arrow-up[data-direction='#{@stack.sorting_direction}']"
    end
  end

  it "renders a multi select box for filtering" do
    render
    assert_select "form[action='#{official_stack_path(@stack)}'][data-controller='stack-controls']" do
      assert_select "select#filters" do
        Stack::ALLOWED_ITEM_TYPES.each do |filter|
          assert_select "option[value='#{filter}']", text: filter.pluralize
        end
      end
    end
  end
end
