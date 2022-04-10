class AddIndexToParkingViolationsPlateNumber < ActiveRecord::Migration[5.2]
  def change
    add_index :parking_violations, :plate_number
  end
end
