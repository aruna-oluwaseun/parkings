module DropdownFields
  module Dashboard
    class RoleId < ::DropdownFields::Base
      def execute
        admin = Admin.find(params[:admin_id])
        return Role.all if admin.admin?
        Role.where(name: ::Role::PERMITTED_CREATABLE_ROLES[admin.role.name.underscore.to_sym])
      end

      def value_attr
        :id
      end

      def label_attr
        :display_name
      end

    end
  end
end
