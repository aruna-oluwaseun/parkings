module DropdownFields
  module Dashboard
    class RoleNamesFilter < ::DropdownFields::Base

      def execute

        Role.all

      end

      def value_attr
         :display_name
      end

      def label_attr
         :display_name
      end
    end
  end
end
