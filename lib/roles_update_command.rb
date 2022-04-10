class RolesUpdateCommand

  CRUD_OPS = {
    super_admin: ::Role::Permission::PERMISSIONS_AVAILABLE,
    town_manager: %w(Vehicle Camera ParkingLot Agency Payment Dispute Parking::Violation Message Report),
    parking_admin: %w(ParkingLot),
    manager: %w(Agency Parking::Violation),
    officer: %w()
  }.freeze

  READ_OPS = {
    town_manager: %w(),
    parking_admin: %w(Payment Camera Report),
    manager: %w(),
    officer: %w(Agency Parking::Violation)
  }.freeze

  PERMITS = {
    full: {
      record_create: true,
      record_update: true,
      record_read: true,
      record_delete: true
    },
    readonly: {
      record_create: false,
      record_update: false,
      record_read: true,
      record_delete: false
    }
  }.freeze

  def self.execute
    new.execute
  end

  def execute
    update_permissions(CRUD_OPS, true)
    update_permissions(READ_OPS, false)
    Role.where(name: :super_admin).update_all(full: true)
  end

  def update_permissions(ops, full)
    ops.each do |role_name, entities|
      role = ::Role.find_or_create_by(name: role_name)
      role.display_name = I18n.t("role.#{role_name}")
      role.save!
      entities.each do |entity|
        permission = role.permissions.find_or_create_by(name: entity)
        permission.update(full ? PERMITS[:full] : PERMITS[:readonly])
      end
    end
  end
end
