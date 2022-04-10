module Roles
  class Create < Base
    attr_reader :role

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

    validates :permissions, :name, presence: true
    validate  :validate_permissions_name
    validate  :existence_of_permissions

    # @return [Hash]
    def execute
      ActiveRecord::Base.transaction do
        @role = transactional_create!(Role, role_params)
        if errors.any?
          raise ActiveRecord::Rollback
        else
          create_permissions
        end
      end
      self
    end

    private

    # This method creates the role permissions.
    # @return [boolean]
    def create_permissions
      permissions.each do |permission|
        params = {
          role_id: @role.id,
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
  end
end
