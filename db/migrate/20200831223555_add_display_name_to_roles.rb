class AddDisplayNameToRoles < ActiveRecord::Migration[5.2]
  def change
    add_column :roles, :display_name, :string
  end
end
