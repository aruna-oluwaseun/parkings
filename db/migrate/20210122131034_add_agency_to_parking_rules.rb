class AddAgencyToParkingRules < ActiveRecord::Migration[5.2]
  def change
    add_reference :parking_rules, :agency, foreign_key: true
  end
end
