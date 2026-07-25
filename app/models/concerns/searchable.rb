module Searchable
  extend ActiveSupport::Concern

  included do
    include Typesense

    class_attribute :search_schema, default: nil
  end

  class DSL
    def initialize(model, index_settings)
      @model = model
      @index_settings = index_settings
    end

    def set_schema(schema)
      @model.search_schema = schema
      @index_settings.predefined_fields(schema)
    end

    def method_missing(name, *args, &block)
      if @index_settings.respond_to?(name)
        @index_settings.public_send(name, *args, &block)
      else
        super
      end
    end

    def respond_to_missing?(name, include_private = false)
      @index_settings.respond_to?(name, include_private) || super
    end
  end

  class_methods do
    def searchable(options = {}, &block)
      options = {collection_name: collection_name}.merge(options)
      model = self

      typesense(options) do
        dsl = DSL.new(model, self)
        dsl.instance_exec(&block) if block
      end
    end

    def collection_name
      "#{model_name}_#{Rails.env}#{ENV["TEST_ENV_NUMBER"]}"
    end
  end
end
