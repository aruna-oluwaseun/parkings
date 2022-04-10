class RenameRegistrationCountryColumn < ActiveRecord::Migration[5.2]
  def change
    rename_column :vehicles, :registration_country, :registration_state
  end
end
