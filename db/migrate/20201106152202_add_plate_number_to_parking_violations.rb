class AddPlateNumberToParkingViolations < ActiveRecord::Migration[5.2]
  def change
    add_column :parking_violations, :plate_number, :string
  end
end
