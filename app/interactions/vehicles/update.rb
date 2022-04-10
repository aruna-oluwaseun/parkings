module Vehicles
  class Update < Base
    object :vehicle, class: Vehicle
    string :plate_number
    string :color, default: nil
    string :vehicle_type, default: nil
    string :status, default: 'pending'
    integer :manufacturer_id
    string :model
    string :registration_state, default: nil
    interface :registration_card, default: nil

    validates :plate_number, :model, :manufacturer_id, presence: true
    validate :validates_registration_card

    def execute
      vehicle.update(vehicle_params)
      errors.merge!(vehicle.errors) if vehicle.errors.any?
    end

    def vehicle_params
      data = inputs.except(:vehicle)
      if data[:registration_card].present?
        data[:registration_card] = { data: inputs[:registration_card] }
      else
        data.delete(:registration_card)
      end

      data
    end
  end
end
