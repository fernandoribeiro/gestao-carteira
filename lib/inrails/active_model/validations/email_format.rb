module ActiveModel
  module Validations
    class EmailFormatValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        unless value.blank? && options[:allow_blank]
          unless value =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
            record.errors.add(attribute, :invalid, options)
          end
        end
      end
    end
  end
end
