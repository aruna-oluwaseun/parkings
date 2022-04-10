module DropdownFields
  module Dashboard
    class CategoriesPlace < ::DropdownFields::Base

      def execute
        Place.categories.keys.map { |key| { name: key, label: key.titleize } }
      end

      def value_attr
        :name
      end

      def label_attr
        :label
      end

    end
  end
end
