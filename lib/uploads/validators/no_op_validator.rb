module Uploads::Validators
  # Used in cases where the image validator could not be determined
  class NoOpValidator < Base
    def valid?(context = nil)
      errors.add(:record, "is unknown")
      false
    end
  end
end
