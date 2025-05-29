module Uploads::Validators
  class Base
    include ActiveModel::Validations

    validate :validate_width, :validate_height, :validate_aspect_ratio

    def initialize(width:, height:, aspect_ratio:)
      @width = width
      @height = height
      @aspect_ratio = aspect_ratio
    end

    def self.for(klass:, field:)
      field = field.to_s.titleize.sub(" ", "")
      "Uploads::Validators::#{klass}#{field}Validator".constantize
    rescue
      NoOpValidator
    end

    def validate_width
      errors.add(:width, "must be between #{minimum_width}px and #{maximum_width}px") unless width_valid?
    end

    def width_valid? = @width.between?(minimum_width, maximum_width)

    def validate_height
      errors.add(:height, "must be between #{minimum_height}px and #{maximum_height}px") unless height_valid?
    end

    def height_valid? = @height.between?(minimum_height, maximum_height)

    def validate_aspect_ratio
      errors.add(:aspect_ratio, "must be #{width_aspect}:#{height_aspect}") unless aspect_ratio_valid?
    end

    def aspect_ratio_valid?
      (@aspect_ratio - required_aspect_ratio).abs <= 0.01
    end

    private

    def required_aspect_ratio = width_aspect.to_f / height_aspect.to_f

    def minimum_width = raise "Implement in subclass"

    def maximum_width = raise "Implement in subclass"

    def minimum_height = raise "Implement in subclass"

    def maximum_height = raise "Implement in subclass"

    def width_aspect = raise "Implement in subclass"

    def height_aspect = raise "Implement in subclass"
  end
end
