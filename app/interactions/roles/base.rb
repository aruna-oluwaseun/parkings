module Roles
  class Base < ::ApplicationInteraction

    def to_model
      role.reload
    end

    private

    # @overload role_params
    # This method set the display_name field in the new role since the name field is only for predefined roles.
    # @return [Hash]
    def role_params
      data  = inputs.slice(:full)
      data[:display_name] = inputs[:name]
      data
    end

    # This method checks that the name of each permission is valid
    # @return [Hash]
    def validate_permissions_name
      permissions.each do |permission|
        unless ::Role::Permission::PERMISSIONS_AVAILABLE.include?(permission['name'])
          errors.add(:permission, :invalid_name)
        end
      end
    end

    # This method creates the permissions for each attribute.
    # If the permission array is present, then it will be used.
    # If not, the same values of the main permission are set by default for each attribute.
    # @return [boolean]
    def create_permission_attributes
      if @attributes.present?
        @attributes.each do |attribute|
          @permission.attrs.create!(name: attribute['name'], attr_read: attribute['attr_read'], attr_update: attribute['attr_update'])
        end
      else
        admin_roles = Role::NAMES.map { |role| role.to_s.camelcase }
        permission_model = if @permission.name.in?(admin_roles)
                             Admin
                           else
                             @permission.name.singularize.classify.constantize rescue "Parking::#{@permission.name}".singularize.classify.constantize
                           end
        permission_model.column_names.each do |column|
          @permission.attrs.create!(name: column, attr_read: @permission.record_read, attr_update: @permission.record_update)
        end
      end
    end

    def existence_of_permissions
      all_is_blank = permissions.all? do |permission|
        %w(record_create record_read record_update record_delete).all? do |action|
          permission[action].blank?
        end
      end

      if all_is_blank
        errors.add(:permissions, 'Atleast 1 permission should be defined')
      end
    end
  end
end
