class DropTownsTable < ActiveRecord::Migration[5.2]
  def change
    remove_column :parking_lots, :town_id
    drop_table :towns
  end
end
