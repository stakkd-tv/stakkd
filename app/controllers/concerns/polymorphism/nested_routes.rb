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
    #
    # For some nested routes e.g. /shows/gintama/seasons/1/videos
    # we need to account for the show_id e.g.
    # show_season_videos_path(season, show_id: show), which is why
    # we look at the ordered keys that contain _id in the params.
    def nested_path_for(relatable:, resource: nil)
      resource_name = resource_name_from_params
      relatable_name = relatable_name_from_record(relatable)

      keys_without_relatable = id_keys_from_params.keys - ["#{relatable_snake_case(relatable)}_id"]
      ids = keys_without_relatable.map { |key| params[key] }
      ids << relatable

      nested_path = "#{relatable_name}_#{resource_name}_path"
      nested(nested_path, ids, resource)
    end

    private

    def nested(url_helper, relatable_ids, resource)
      return send(url_helper, *relatable_ids) unless resource
      send(url_helper, *relatable_ids, resource)
    end

    def resource_name_from_params
      inflection = params[:id].present? ? "singular" : "plural"
      params[:controller].split("/").last.send("#{inflection}ize")
    end

    def relatable_name_from_record(relatable)
      return unless relatable
      if is_nested?
        id_keys_from_params.keys.map do |key|
          key.to_s.gsub(/_id$/, "")
        end.join("_")
      else
        relatable_snake_case(relatable)
      end
    end

    def relatable_snake_case(relatable)
      return unless relatable
      relatable.class.name.underscore
    end

    # TODO: DRY these methods from Polymorphism::Relatable
    def id_keys_from_params
      params.select { |key, _| /(.+)_id$/.match?(key) }
    end

    def is_nested?
      id_keys_from_params.keys.size > 1
    end
  end
end
