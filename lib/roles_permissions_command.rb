class RolesPermissionsCommand
  def self.execute
    new.execute
  end

  def execute
    ownership = {
      town_manager: :super_admin,
      parking_admin: :town_manager,
      manager: :town_manager,
      officer: :manager
    }

    #CRUD operations
    crud_operations = {
      super_admin: Role::Permission::PERMISSIONS_AVAILABLE,
      town_manager: %w(Rule Vehicle VehicleRule Camera ParkingLot ParkingSlot CoordinateParkingPlan ParkingSession Agency Payment Dispute Violation Message Report ParkingAdmin),
      parking_admin: %w(CoordinateParkingPlan),
      manager: %w(Violation Ticket Agency Officer),
      officer: %w()
    }

    read_operations = {
      town_manager: %w(TownManager),
      parking_admin: %w(ParkingSession ParkingLot Payment Camera Report),
      manager: %w(Manager),
      officer: %w(Officer Agency Violation Ticket)
    }

    admin_roles = Role::NAMES.map { |role| role.to_s.camelcase }

    system_admin_role = Role.find_by(name: 'system_admin')
    super_admin_role = Role.find_by(name: 'super_admin')

    if system_admin_role.present?
      system_admin_role.admins.each do |admin|
        admin.role_id = super_admin_role.id
        admin.save!
      end

      system_admin_role.destroy!
    end

    Role::NAMES.each do |role_name|
      role = Role.find_by(name: role_name)
      role.update(display_name: role_name.to_s.humanize)

      if ownership[role_name]
        role.parent = Role.find_by(name: ownership[role_name])
      end

      role.save!
      role.permissions.destroy_all

      crud_operations[role_name].each do |permission_name|
        permission = role.permissions.create!(
          name: permission_name,
          record_create: true,
          record_update: true,
          record_read: true,
          record_delete: true
        )
        permission_model = if permission_name.in?(admin_roles)
                            Admin
                           else
                             permission_name.singularize.classify.constantize rescue "Parking::#{permission_name}".singularize.classify.constantize
                           end
        column_names = permission_model.column_names
        column_names = (column_names + Role::Permission.extra_permissions(permission_name)).uniq
        column_names.each do |column|
          permission.attrs.create!(name: column, attr_read: true, attr_update: true)
        end

      end

      read_operations[role_name]&.each do |role_read_name|
        permission = role.permissions.create!(
          name: role_read_name,
          record_read: true
        )
        permission_model = if role_read_name.in?(admin_roles)
                            Admin
                           else
                             role_read_name.singularize.classify.constantize rescue "Parking::#{role_read_name}".singularize.classify.constantize
                           end
        column_names = permission_model.column_names
        column_names = (column_names + Role::Permission.extra_permissions(role_read_name)).uniq
        column_names.each do |column|
          permission.attrs.create!(name: column, attr_read: true, attr_update: false)
        end
      end
    end

    Role.where(name: :super_admin).update_all(full: true)
  end
end
