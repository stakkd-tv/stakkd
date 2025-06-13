module Polymorphism
  module Relatable
    extend ActiveSupport::Concern

    included do
      before_action :set_relatable_or_not_found
      helper_method :relatable_model
      helper_method :relatable_model_plural
    end

    private

    def relatable_model_plural
      relatable_model.pluralize
    end

    def relatable_model
      _, param = relatable_class_from_params
      param.sub("_id", "")
    end

    def relatable
      klass, param = relatable_class_from_params
      klass&.from_slug(params[param.to_sym])
    end

    def relatable_class_from_params
      params.each do |key, value|
        if /(.+)_id$/.match?(key)
          model = key.match(%r{([^\/.]*)_id$})
          return model[1].classify.constantize, key
        end
      end
      nil
    end

    def set_relatable_or_not_found
      @relatable = relatable
      head :not_found unless @relatable
    end
  end
end
