class AssignAgenciesOfficerToRule < ActiveRecord::Migration[5.2]
  def change
    add_reference :parking_rules, :admin, index: true
  end
end
