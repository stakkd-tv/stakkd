class ImagesController < ApplicationController
  class InvalidRecordType < StandardError; end

  before_action :validate_record_id
  before_action :set_record
  before_action :validate_type
  before_action :validate_image

  VALID_CONTENT_TYPES = [
    "image/jpg",
    "image/jpeg",
    "image/png"
  ]

  rescue_from InvalidRecordType, with: :rescue_model

  def upload
    validator = Uploads::Validators::Base.for(klass: model, field: type)
    upload = Uploads::Upload.new(record: @record, field: type, image:, validator_class: validator)
    unless upload.validate_and_save!
      render json: {message: upload.errors.full_messages.join(", ")}, status: 422
      return
    end
    render json: {image: upload.url}
  end

  private

  def model
    params[:record_type].constantize
  rescue
    raise InvalidRecordType
  end

  def rescue_model
    render json: {message: "Invalid record type"}, status: 400
  end

  def set_record
    @record = model.find(params[:record_id])
  end

  def validate_record_id
    return if params[:record_id].present?
    render json: {message: "Record ID is not present"}, status: 400
  end

  def validate_type
    type_valid = @record.respond_to?(type) && @record.respond_to?("#{type}=")
    return if type_valid
    render json: {message: "Invalid type"}, status: 400
  end

  def image = params[:image]

  def type = params[:type].to_s.to_sym

  def validate_image
    return render json: {message: "No image supplied"}, status: 400 unless image
    return render json: {message: "Not a valid file"}, status: 400 unless image.respond_to?(:content_type)
    render json: {message: "Invalid content type"}, status: 400 unless VALID_CONTENT_TYPES.include?(image.content_type)
  end
end
