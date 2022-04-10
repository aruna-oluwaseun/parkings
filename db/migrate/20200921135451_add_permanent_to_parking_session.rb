class AddPermanentToParkingSession < ActiveRecord::Migration[5.2]
  def change
    add_column :parking_sessions, :permanent, :boolean, default: false
  end
end
