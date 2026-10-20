class OfficialStacksController < ApplicationController
  include StackConcerns

  before_action :set_stack

  # TODO: System specs for actions for each stack item - mark as watched etc?
  def show = stack_show

  private

  def set_stack
    @stack = Stack.official.from_slug(params[:id])
  end
end
