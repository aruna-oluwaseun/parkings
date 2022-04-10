class AddPlateNumberVerifiedToParkingSession < ActiveRecord::Migration[5.2]
  def change
    add_column :parking_sessions, :plate_number_verified, :bool, default: false
  end
end
