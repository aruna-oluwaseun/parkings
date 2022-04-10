class AddReferencesToAgencyType < ActiveRecord::Migration[5.2]
  def change
    add_reference :agencies, :agency_type, foreign_key: true
  end
end
