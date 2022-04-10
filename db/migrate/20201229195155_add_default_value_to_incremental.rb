class AddDefaultValueToIncremental < ActiveRecord::Migration[5.2]
  def change
    change_column :parking_settings, :incremental, :integer, default: 3600
  end
end
