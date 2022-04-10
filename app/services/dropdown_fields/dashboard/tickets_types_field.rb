module DropdownFields
  module Dashboard
    class TicketsTypesField < ::DropdownFields::Base

      def execute
        ::Parking::Rule.names.keys.map do |key|
          { label: I18n.t("activerecord.models.rules.description.#{key}"), value: key }
        end
      end

      def value_attr
        :value
      end

      def label_attr
        :label
      end

    end
  end
end
