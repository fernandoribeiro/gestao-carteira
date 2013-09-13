module ActiveModel
  module Validations
    class CpfValidator < ActiveModel::EachValidator
      @@black_list = %w(
        12345678909
        11111111111
        22222222222
        33333333333
        44444444444
        55555555555
        66666666666
        77777777777
        88888888888
        99999999999
        00000000000
      )

      def validate_each(record, attribute, value)
        unless value.blank? && options[:allow_blank]
          unless valid_cpf?(value)
            record.errors.add(attribute, :cpf, options)
          end
        end
      end

      def valid_cpf?(value)
        cpf = value

        if cpf !~ /^\d{10,11}|\d{3}\.\d{3}\.\d{3}-\d{2}$/
          return false
        end

        cpf = cpf.scan(/\d/).collect(&:to_i)
        cpf.unshift(0) if cpf.length == 10

        if @@black_list.member? cpf.join.to_s
          return false
        end

        sum = (0..8).inject(0) do |sum, i|
          sum + (cpf[i] * (10 - i))
        end

        result = sum % 11
        result = result < 2 ? 0 : 11 - result

        unless result == cpf[9]
          return false
        end

        sum = (0..8).inject(0) do |sum, i|
          sum + (cpf[i] * (11 - i))
        end

        sum += cpf[9] * 2

        result = sum % 11
        result = result < 2 ? 0 : 11 - result

        return result == cpf[10]
      end
    end
  end
end
