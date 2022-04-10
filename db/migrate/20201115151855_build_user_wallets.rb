class BuildUserWallets < ActiveRecord::Migration[5.2]
  def change
    Build::UserWalletsBuilder.new.call
  end
end
