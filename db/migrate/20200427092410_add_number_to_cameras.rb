class AddNumberToCameras < ActiveRecord::Migration[5.2]
  def change
    add_column :cameras, :number, :integer
  end
end
