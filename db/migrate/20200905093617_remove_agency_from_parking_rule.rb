class RemoveAgencyFromParkingRule < ActiveRecord::Migration[5.2]
  def change
    remove_reference :parking_rules, :agency
  end
end
