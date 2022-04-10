class AddReferenceNumberToPayments < ActiveRecord::Migration[5.2]
  def change
    add_column :payments, :reference_number, :string
  end
end
