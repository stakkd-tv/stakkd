module Tabulator
  class Base
    def initialize(records)
      @records = records
    end

    def table_data
      @records.map do |record|
        to_hash(record)
      end
    end

    # See https://tabulator.info/docs/6.3/columns#definition for more info.
    def column_defs = raise "Implement in subclass"

    def model_table_name = raise "Implement in subclass"

    private

    def to_hash(record) = raise "Implement in subclass"
  end
end
