class AddKskPlateNumberToParkingSession < ActiveRecord::Migration[5.2]
  def change
    add_column :parking_sessions, :ksk_plate_number, :string
  end
end
