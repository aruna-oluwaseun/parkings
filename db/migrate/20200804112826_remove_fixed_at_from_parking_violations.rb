class RemoveFixedAtFromParkingViolations < ActiveRecord::Migration[5.2]
  def change
    remove_column :parking_violations, :fixed_at, :datetime
  end
end
