class RolesSeedCommand
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
      town_manager: %w(Vehicle Camera ParkingLot Agency Payment Dispute Parking::Violation Message Report Parking::CitationTicket),
      parking_admin: %w(ParkingLot),
      manager: %w(Agency Message Parking::Violation Parking::CitationTicket),
      officer: %w(Message Parking::Violation Parking::CitationTicket)
    }

    read_operations = {
      town_manager: %w(),
      parking_admin: %w(Payment Camera Report Parking::Violation),
      manager: %w(),
      officer: %w(Agency)
    }

    admin_roles = Role::NAMES.map { |role| role.to_s.camelcase }

    Role::NAMES.each do |role_name|
      role = Role.new(name: role_name, display_name: I18n.t('role')[role_name])

      if ownership[role_name]
        role.parent = Role.find_by(name: ownership[role_name])
      end

      role.save!

      crud_operations[role_name].each do |permission_name|
        role.permissions.create!(
          name: permission_name,
          record_create: true,
          record_update: true,
          record_read: true,
          record_delete: true
        )
      end

      read_operations[role_name]&.each do |role_read_name|
        role.permissions.create!(
          name: role_read_name,
          record_read: true
        )
      end
    end

    Role.where(name: :super_admin).update_all(full: true)
  end
end
