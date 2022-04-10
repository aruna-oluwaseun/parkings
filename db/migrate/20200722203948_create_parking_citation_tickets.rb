class CreateParkingCitationTickets < ActiveRecord::Migration[5.2]
  def change
    create_table :parking_citation_tickets do |t|
      t.string :description
      t.references :violation, foreign_key: { to_table: :parking_violations }
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
