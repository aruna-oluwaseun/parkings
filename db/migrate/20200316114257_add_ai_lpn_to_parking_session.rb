class AddAiLpnToParkingSession < ActiveRecord::Migration[5.2]
  def change
    add_column :parking_sessions, :ai_plate_number, :string
  end
end
