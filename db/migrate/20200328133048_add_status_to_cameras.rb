class AddStatusToCameras < ActiveRecord::Migration[5.2]
  def change
    add_column :cameras, :status, :integer, default: 0
  end
end
