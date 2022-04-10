module DropdownFields
  module Mobile
    class CountriesList < ::DropdownFields::Base

      def execute
        Carmen::Country.all.map { |country| { code: country.code, name: country.name } }
      end

      def value_attr
        :code
      end

      def label_attr
        :name
      end

    end
  end
end
