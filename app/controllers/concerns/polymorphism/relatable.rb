module Polymorphism
  module Relatable
    extend ActiveSupport::Concern

    included do
      before_action :set_relatable_or_not_found
      helper_method :relatable_model_plural
    end

    private

    def relatable_model_plural
      _, param = relatable_class_from_params
      param.gsub(/_id$/, "").pluralize
    end

    def relatable
      if is_nested?
        relatable_from_nested_params
      else
        klass, param = relatable_class_from_params
        klass&.from_slug(params[param.to_sym])
      end
    end

    # In cases where the URL is something like /shows/gintama/seasons/1/galleries/posters, we need to know what the relatable actually is.
    # In all cases, the last part of the url that contains an ID (in this case, `/seasons/1`) tells us exactly the type of record relatable
    # will be. However, we also need to look at all previous IDs to determine how to get the record,
    # e.g. /shows/gintama/seasons/1/episodes/1/galleries/posters, we need the 1st episode of the 1st season of Gintama.
    # This method relies on the fact that Rails params are ordered by depth. e.g.
    # {"controller" => "galleries", "action" => "posters", "show_id" => "gintama", "season_id" => "1"}
    # So with this information we can traverse through the relations and get the actual record we need.
    def relatable_from_nested_params
      parent_record_param = id_keys_from_params.keys.first
      parent_record_klass = parent_record_param.match(%r{([^\/.]*)_id$})[1].classify.constantize
      parent_record = parent_record_klass&.from_slug(params[parent_record_param])
      return unless parent_record

      id_keys_without_parent = id_keys_from_params.keys - [parent_record_param]
      methods = id_keys_without_parent.map do |key, value|
        {method: key.to_s.gsub(/_id$/, "").pluralize, param: key}
      end

      relation = parent_record
      methods.each do |hash|
        next unless relation

        method = hash[:method]
        param = hash[:param]
        relation = relation.send(method.to_sym).nested(params[param]).first
      end
      relation
    end

    # This relies on the fact that Rails orders params by depth, e.g.
    # {"controller" => "galleries", "action" => "posters", "show_id" => "over-the-garden-wall-7", "season_id" => "1"}
    # In the above example, seasons belong to shows. In any case, the actual param that we want is the LAST param that has _id in it.
    def relatable_class_from_params
      id_keys_from_params.keys.reverse_each do |key|
        model = key.match(%r{([^\/.]*)_id$})
        return model[1].classify.constantize, key
      end
      nil
    end

    def id_keys_from_params
      params.select { |key, _| /(.+)_id$/.match?(key) }
    end

    def is_nested?
      id_keys_from_params.keys.size > 1
    end

    def set_relatable_or_not_found
      @relatable = relatable
      head :not_found unless @relatable
    end
  end
end
