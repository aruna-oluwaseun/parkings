class AddRegistrationCountryAndRegistrationCardToVehicles < ActiveRecord::Migration[5.2]
  def change
    add_column :vehicles, :registration_country, :string
    add_column :vehicles, :registration_card, :string
  end
end
