class PeopleController < ApplicationController
  before_action :require_authentication, except: [:index, :show]
  before_action :set_person, only: [:show, :edit, :update, :images]

  def index
    @people = if params[:query]
      Person.with_attached_images.search(params[:query]).order(:translated_name)
    else
      Person.with_attached_images.order(:translated_name)
    end
  end

  def show
    @gallery_presenter = Galleries::Presenter.new(@person)
    credits = Credits.new(@person)
    @possible_tabs = credits.credit_types
    @credit_type = @possible_tabs.dup.delete(params[:credit_type]) || @possible_tabs.first
    @credits = (@credit_type == "cast") ? credits.as_cast_member : credits.as_crew_member
  end

  def new
    @person = Person.new
  end

  def edit
  end

  def create
    @person = Person.new(person_params)

    if @person.save
      redirect_to edit_person_path(@person), notice: "Person was successfully created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @person.update(person_params)
      redirect_to @person, notice: "Person was successfully updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def images
  end

  private

  def set_person
    @person = Person.from_slug(params.expect(:id))
  end

  def person_params
    params.expect(person: [:alias, :biography, :dob, :dod, :gender, :imdb_id, :known_for, :original_name, :translated_name])
  end

  def images_params
    params.expect(person: [images: []])
  end
end
