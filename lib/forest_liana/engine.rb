require 'rack/cors'
require 'stripe'
require 'jsonapi-serializers'
require 'groupdate'
require 'http'

module ForestLiana
  class Engine < ::Rails::Engine
    isolate_namespace ForestLiana
    logger = Logger.new(STDOUT)

    config.middleware.insert_before 0, 'Rack::Cors' do
      allow do
        origins '*'
        resource '*', headers: :any, methods: :any
      end
    end

    config.after_initialize do
      unless Rails.env.test?
        SchemaUtils.tables_names.map do |table_name|
          model = SchemaUtils.find_model_from_table_name(table_name)
          SerializerFactory.new.serializer_for(model) if \
            model.try(:table_exists?)
        end

        # Monkey patch the find_serializer_class_name method to specify the good
        # serializer to use.
        JSONAPI::Serializer.class_eval do
          def self.find_serializer_class_name(obj)
            SerializerFactory.get_serializer_name(obj.class)
          end
        end
      end

      if ForestLiana.jwt_signing_key
        forest_url = ENV['FOREST_URL'] ||
          'https://forestadmin-server.herokuapp.com';

        apimaps = []
        SchemaUtils.tables_names.map do |table_name|
          model = SchemaUtils.find_model_from_table_name(table_name)
          apimaps << SchemaAdapter.new(model).perform if model.try(:table_exists?)
        end

        liana_version = Gem::Specification.find_by_name('forest_liana')
          .version.to_s
        json = JSONAPI::Serializer.serialize(apimaps, {
          is_collection: true,
          meta: { liana: 'forest-rails', liana_version: liana_version }
        })
        response = HTTP
          .headers(forest_secret_key: ForestLiana.jwt_signing_key)
          .post("#{forest_url}/forest/apimaps", json: json)

        if response.status_code != 204
          logger.warn "Forest cannot find your project secret key. Please, " \
            "run `rails g forest_liana:install`."
        end
      end
    end
  end
end
