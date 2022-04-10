class RemoveColumnsFromPayments < ActiveRecord::Migration[5.2]
  def change
    remove_column :payments, :payment_gateway, :string
    remove_column :payments, :meta_data, :json
    remove_column :payments, :reference_number, :string
    remove_column :payments, :card_last_four_digits, :string
  end
end
