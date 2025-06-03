module Uploads::Validators
  class MovieBackgroundsValidator < Base
    private

    def minimum_width = 1280

    def maximum_width = 3840

    def minimum_height = 720

    def maximum_height = 2160

    def width_aspect = 16

    def height_aspect = 9
  end
end
