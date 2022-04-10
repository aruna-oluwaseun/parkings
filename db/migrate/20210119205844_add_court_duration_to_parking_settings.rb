class AddCourtDurationToParkingSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :parking_settings, :court_duration, :integer, default: 25
  end
end
