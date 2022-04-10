class FixReadPermissionParkingAdmin < ActiveRecord::Migration[5.2]
  def up
    role = Role.where(name: "parking_admin").first
    if role.present? && !role.permissions.where(name: "Parking::Violation").exists?
      role.permissions.create!(
        name: "Parking::Violation",
        record_read: true
      )
    end
  end
end
