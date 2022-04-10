class CreateParkingHistories < ActiveRecord::Migration[5.2]
  def change
    create_table :parking_histories do |t|
      t.references :user, foreign_key: true
      t.references :parking_session, foreign_key: true

      t.timestamps
    end
  end
end
