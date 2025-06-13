module Polymorphism
  module NestedRoutes
    extend ActiveSupport::Concern

    included do
      helper_method :nested_path_for
    end

    # Resource: The record with the polymorphic relation
    # Relatable: The record that the resource is related to
    # E.g. for AlternativeName, resource will be the
    # AlternativeName and relatable could be a Movie, Show etc
    def nested_path_for(relatable:, resource: nil)
      resource_name = resource_name_from_params
      relatable_name = relatable_snake_case(relatable)

      nested_path = "#{relatable_name}_#{resource_name}_path"
      nested(nested_path, relatable, resource)
    end

    private

    def nested(url_helper, relatable, resource)
      return send(url_helper, relatable) unless resource
      send(url_helper, relatable, resource)
    end

    def resource_name_from_params
      inflection = params[:id].present? ? "singular" : "plural"
      params[:controller].split("/").last.send("#{inflection}ize")
    end

    def relatable_snake_case(relatable)
      return unless relatable
      relatable.class.name.underscore
    end
  end
end
