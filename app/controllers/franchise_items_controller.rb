class FranchiseItemsController < ApplicationController
  before_action :require_authentication
  before_action :set_franchise
  before_action :set_franchise_item, only: [:update, :destroy]

  def editor
    @table_presenter = Tabulator::FranchiseItemsPresenter.new(@franchise.ordered_franchise_items.includes(:record))
  end

  def create
    @franchise_item = @franchise.franchise_items.new(franchise_item_params)
    if @franchise_item.save
      redirect_to editor_franchise_franchise_items_path(@franchise)
    else
      redirect_to editor_franchise_franchise_items_path(@franchise), alert: "Item could not be added."
    end
  end

  def update
    if @franchise_item.update(franchise_item_params)
      render json: {success: true}, status: 200
    else
      errors = @franchise_item.errors.group_by_attribute.each_pair.map { |field, errors| {field => errors.map(&:full_message)} }
      render json: {success: false, errors:}, status: 422
    end
  end

  def destroy
    @franchise_item.destroy
    head :no_content
  end

  private

  def franchise_item_params
    params.expect(franchise_item: [:record_type, :record_id])
  end

  def set_franchise_item
    @franchise_item = @franchise.franchise_items.find(params.expect(:id))
  end

  def set_franchise
    @franchise = Franchise.from_slug(params.expect(:franchise_id))
  end
end
