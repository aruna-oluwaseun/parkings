class RemoveUniqueIndexFromParkingViolationsPlateNumber < ActiveRecord::Migration[5.2]
  def change
    remove_index :parking_violations, column: :plate_number, unique: true 
    add_index :parking_violations, :plate_number
  end
end
