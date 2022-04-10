module Api
  module Dashboard
    class RoleSerializer < ::ApplicationSerializer
      attributes :id, :name, :full, :predefined_role, :deletable, :permissions

      attribute :created_at do
        utc(object.created_at)
      end

      attribute :updated_at do
        utc(object.updated_at)
      end

      def name
        object.name? ? I18n.t("role.#{object.name}") : object.display_name
      end

      def predefined_role
        object.name?
      end

      def deletable
        object.admins.none? && object.name.nil?
      end

      def permissions
        object.permissions.as_json(
          only: [:name, :record_create, :record_read, :record_update, :record_delete],
          include: {
            attrs: {
              only: [:name, :attr_read, :attr_update]
            }
          }
        )
      end
    end
  end
end
