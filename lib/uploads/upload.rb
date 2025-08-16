module Uploads
  class Upload
    attr_reader :record, :field, :image, :validator_class

    delegate :errors, to: :validator
    delegate :url, to: :blob

    def initialize(record:, field:, image:, validator_class:)
      @record = record
      @field = field
      @image = image
      @validator_class = validator_class
    end

    def validate_and_save!
      if validator.invalid?
        blob.purge
        return false
      end

      record.send(field).attach(blob)
      true
    end

    private

    def validator
      @validator ||= validator_class.new(width:, height:, aspect_ratio:)
    end

    def width = blob.metadata[:width]

    def height = blob.metadata[:height]

    def aspect_ratio = (width.to_f / height.to_f).round(2)

    def blob
      @blob ||= ActiveStorage::Blob.create_and_upload!(
        io: image.tempfile,
        filename: image.original_filename,
        content_type: image.content_type
      ).tap { it.analyze }
    end
  end
end
