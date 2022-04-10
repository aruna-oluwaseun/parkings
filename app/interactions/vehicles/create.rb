module Vehicles
  class Create < Base
    attr_reader :vehicle

    object :user, class: User
    string :plate_number
    string :color, default: nil
    string :vehicle_type, default: nil
    integer :manufacturer_id
    string :model
    string :status, default: 'pending'
    string :registration_state
    interface :registration_card

    validates :plate_number,
              :model,
              :manufacturer_id,
              :registration_state,
              :registration_card, presence: true

    validate :validates_registration_card

    def execute
      if user.vehicles.count >= User::VEHICLES_MAX_COUNT
        errors.add(:base, :more_than_max_count)
        return self
      end

      @vehicle = Vehicle.find_by(plate_number: plate_number&.remove_non_alphanumeric&.downcase)

      if @vehicle.present?
        if @vehicle.user_id.present?
          errors.add(:base, :already_taken_by_another_account, { plate_number: plate_number })
          return self
        end
        @vehicle.update(vehicle_params.merge(user_id: user.id))
      else
        @vehicle = user.vehicles.create(vehicle_params)
        VehicleMailer.create(@vehicle.id).deliver_later
      end

      errors.merge!(vehicle.errors) if vehicle.errors.any?
      self
    end

    def to_model
      vehicle.reload
    end

    def vehicle_params
      data = inputs.slice(:plate_number, :color, :vehicle_type, :manufacturer_id, :model, :registration_state)
      data[:registration_card] = { data: inputs[:registration_card] }
      data
    end

    # @overload validates_registration_card
    # This method checks that vehicle registration card image file size is less than 10 megabytes
    # @return[Hash]
    def validates_registration_card
      errors.add(:registration_card, :invalid_file_size) if registration_card && registration_card.size > 10.megabytes
    end
  end
end
