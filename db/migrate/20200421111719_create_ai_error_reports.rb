class CreateAiErrorReports < ActiveRecord::Migration[5.2]
  def change
    create_table :ai_error_reports do |t|
      t.integer :error_type
      t.json :extra_data
      t.references :parking_session, foreign_key: true

      t.timestamps
    end
  end
end
