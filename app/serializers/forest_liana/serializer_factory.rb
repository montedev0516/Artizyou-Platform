require 'jsonapi-serializers'

module ForestLiana
  class SerializerFactory

    def self.define_serializer(active_record_class, serializer)
      class_name = active_record_class.table_name.classify
      module_name = class_name.deconstantize

      name = module_name if module_name
      name += class_name.demodulize

      ForestLiana.const_set("#{name}Serializer", serializer)
    end

    def self.get_serializer_name(active_record_class)
      if active_record_class == Stripe::Charge
        "ForestLiana::StripePaymentSerializer"
      elsif active_record_class == Stripe::Card
        "ForestLiana::StripeCardSerializer"
      elsif active_record_class == Stripe::Invoice
        "ForestLiana::StripeInvoiceSerializer"
      elsif active_record_class == ForestLiana::Stat
        "ForestLiana::StatSerializer"
      else
        class_name = active_record_class.table_name.classify
        module_name = class_name.deconstantize

        name = module_name if module_name
        name += class_name.demodulize

        "ForestLiana::#{name}Serializer"
      end
    end

    def serializer_for(active_record_class)
      serializer = Class.new {
        include JSONAPI::Serializer

        def self_link
          "/forest#{super.underscore}"
        end

        def type
          object.class.table_name.demodulize.tableize.dasherize
        end

        def format_name(attribute_name)
          attribute_name.to_s
        end

        def unformat_name(attribute_name)
          attribute_name.to_s.underscore
        end

        def relationship_self_link(attribute_name)
          nil
        end

        def relationship_related_link(attribute_name)
          ret = {
            href: "#{self_link}/#{format_name(attribute_name)}"
          }

          relationship_records = object.send(attribute_name)
          if relationship_records.respond_to?(:each)
            ret[:meta] = { count: relationship_records.count }
          end

          ret
        end
      }

      attributes(active_record_class).each do |attr|
        serializer.attribute(attr)
      end

      # Paperclip url attribute
      if active_record_class.respond_to?(:attachment_definitions)
        active_record_class.attachment_definitions.each do |key, value|
          serializer.attribute(key) { |x| object.send(key) }
        end
      end

      SchemaUtils.associations(active_record_class).each do |a|
        serializer.send(serializer_association(a), a.name)
      end

      SerializerFactory.define_serializer(active_record_class, serializer)

      serializer
    end

    private

    def key(active_record_class)
      active_record_class.to_s.tableize.to_sym
    end

    def serializer_association(association)
      case association.macro
      when :has_one, :belongs_to
        :has_one
      when :has_many, :has_and_belongs_to_many
        :has_many
      end
    end

    def attributes(active_record_class)
      active_record_class.column_names.select do |column_name|
        !association?(active_record_class, column_name)
      end
    end

    def association?(active_record_class, column_name)
      foreign_keys(active_record_class).include?(column_name)
    end

    def foreign_keys(active_record_class)
      SchemaUtils.associations(active_record_class).map(&:foreign_key)
    end

  end
end
