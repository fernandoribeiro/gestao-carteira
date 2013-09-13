module ActiveModel
  module Validations
    class IntervalValidator < ::ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        check_options_validity(record, options, :start_at)
        check_options_validity(record, options, :end_at)

        if options[:start_at]
          attribute_name = record.class.human_attribute_name(options[:start_at])
          start_at = record.read_attribute(options[:start_at])
          if value && start_at
            record.errors.add(attribute, :interval, options.merge(:interval => attribute_name)) if options[:allow_equals] ? value < start_at : value <= start_at
          else
            record.errors.add(attribute, :interval, options.merge(:interval => attribute_name))
          end
        elsif options[:end_at]
          attribute_name = record.class.human_attribute_name(options[:end_at])
          end_at = record.read_attribute(options[:end_at])
          if value && end_at
            record.errors.add(attribute, :interval, options.merge(:interval => attribute_name)) if options[:allow_equals] ? value > end_at : value >= end_at
          else
            record.errors.add(attribute, :interval, options.merge(:interval => attribute_name))
          end
        end
      end

      def check_validity!
        unless options.include?(:start_at) ^ options.include?(:end_at)  # ^ == xor, or "exclusive or"
          raise ArgumentError, "Either :start_at or :end_at must be supplied (but not both)"
        end
      end

      private

      def check_options_validity(record, options, name)
        option = options[name]
        if option && !option.is_a?(Symbol) && !option.is_a?(String) && !record.attributes.has_key?(option.to_s)
          raise ArgumentError, "A field reference must be supplied as :#{name}"
        end
      end
    end

    module HelperMethods
      def validates_interval_of(*attr_names)
        validates_with IntervalValidator, _merge_attributes(attr_names)
      end
    end
  end
end
