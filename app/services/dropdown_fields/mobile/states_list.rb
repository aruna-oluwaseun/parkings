module DropdownFields
  module Mobile
    class StatesList < ::DropdownFields::Base

      def execute
        country = Carmen::Country.coded(@params[:country_code])
        country.subregions.map { |state| { code: state.code, name: state.name } }
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
