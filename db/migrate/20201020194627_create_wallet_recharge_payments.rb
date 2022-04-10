class CreateWalletRechargePayments < ActiveRecord::Migration[5.2]
  def change
    create_table :wallet_recharge_payments do |t|
      t.decimal :amount
      t.references :user
      t.integer :status, default: 0
      t.integer :payment_method
      t.string :payment_gateway
      t.json :meta_data
      t.string :card_last_four_digits
      t.string :reference_number

      t.timestamps
    end
  end
end
