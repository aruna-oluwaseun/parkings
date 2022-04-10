module Parking::Rules
  class Create < ApplicationInteraction
    include CreateWithObject

    string :name
    string :description, default: nil
    array :admins, default: []
    integer :lot_id
    boolean :status
    integer :admin_id, default: nil

    def execute
      simple_create(Parking::Rule)
    end
  end
end
