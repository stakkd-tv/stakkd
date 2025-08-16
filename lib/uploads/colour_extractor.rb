module Uploads
  class ColourExtractor
    attr_reader :attachment

    delegate :blob, to: :attachment

    def initialize(attachment:)
      @attachment = attachment
    end

    def extract
      blob.analyze unless blob.analyzed?
      blob.open do |tempfile|
        output = execute_magick(tempfile)
        parsed_output = parse_output(output)
        sort_output(parsed_output)
      end
    end

    private

    def execute_magick(tempfile)
      MiniMagick.convert do |convert|
        convert << tempfile.path
        convert << "-format" << "%c"
        convert << "-colors" << 5
        convert << "-depth" << "8"
        convert << "-alpha" << "off"
        convert << "histogram:info:"
      end
    end

    def parse_output(output)
      output.scan(/^ *(\d+):.*?(#[0-9A-Fa-f]{6})/).map { |size, hex| {size: size.to_i, hex:} }
    end

    def sort_output(parsed_output)
      parsed_output.sort_by { it[:size] }.map { it[:hex] }
    end
  end
end
