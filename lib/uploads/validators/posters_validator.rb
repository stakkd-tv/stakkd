module Uploads::Validators
  class PostersValidator < Base
    private

    def minimum_width = 300

    def maximum_width = 2000

    def minimum_height = 450

    def maximum_height = 3000

    def width_aspect = 2

    def height_aspect = 3
  end
end
