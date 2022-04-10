class AddAgencyToParkingLot < ActiveRecord::Migration[5.2]
  def change
    add_reference :parking_lots, :agency, index: true
  end
end
