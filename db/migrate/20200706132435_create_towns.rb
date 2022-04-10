class CreateTowns < ActiveRecord::Migration[5.2]
  def change
    create_table :towns do |t|
      t.string :name
      t.string :contact_number
      t.string :contact_email
      t.string :avatar
      t.integer :status, default: 0
      t.references :admin, foreign_key: true

      t.timestamps
    end
    add_reference :parking_lots, :town, foreign_key: true
  end
end
