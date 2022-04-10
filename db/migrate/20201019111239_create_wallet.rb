class CreateWallet < ActiveRecord::Migration[5.2]
  def change
    create_table :wallets do |t|
      t.references :user, foreign_key: true
      t.decimal :amount, default: 0.0

      t.timestamps
    end
  end
end
