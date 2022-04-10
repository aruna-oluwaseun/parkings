module Roles
  class Update < Base
    attr_reader :role

    object :role, class: Role
    string :name
    array :permissions do
      hash do
        string :name
        boolean :record_create, default: false
        boolean :record_read, default: false
        boolean :record_update, default: false
        boolean :record_delete, default: false
        array :attrs, default: nil do
          hash do
            string :name
            boolean :attr_read, default: false
            boolean :attr_update, default: false
          end
        end
      end
    end

    validate :validate_permissions_name
    validate :validate_predefined_role
    validate  :existence_of_permissions

    # @return [Hash]
    def execute
      ActiveRecord::Base.transaction do
        transactional_update!(role, role_params)
        if errors.any?
          raise ActiveRecord::Rollback
        else
          update_permissions
        end
      end
      self
    end

    private

    # This method updates the role permissions
    # All permissions must always be present, since the current ones are first removed.
    # @return [boolean]
    def update_permissions
      role.permissions.destroy_all
      permissions.each do |permission|
        params = {
          role_id: role.id,
          name: permission['name'],
          record_create: permission['record_create'],
          record_read: permission['record_read'],
          record_update: permission['record_update'],
          record_delete: permission['record_delete']
        }

        @permission = transactional_create!(Role::Permission, params)
        @attributes = permission['attrs']
        create_permission_attributes
      end
    end

    # This method checks that the current role is NOT a predefined role.
    # @return [Hash]
    def validate_predefined_role
      errors.add(:role, :predefined_role) if role.name?
    end
  end
end
