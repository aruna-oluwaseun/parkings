class AddIncrementalToParkingSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :parking_settings, :incremental, :integer
  end
end
