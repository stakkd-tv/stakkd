module Uploads::Validators
  class CompanyLogosValidator < Base
    private

    def minimum_width = 400

    def maximum_width = 3000

    def minimum_height = 400

    def maximum_height = 3000

    def width_aspect = 1

    def height_aspect = 1
  end
end
