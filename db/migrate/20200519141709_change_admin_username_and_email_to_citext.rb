class ChangeAdminUsernameAndEmailToCitext < ActiveRecord::Migration[5.2]
  def up
    enable_extension("citext")

    change_column :admins, :email, :citext
    change_column :admins, :username, :citext
  end

  def down
    change_column :admins, :email, :string
    change_column :admins, :username, :string
  end
end
