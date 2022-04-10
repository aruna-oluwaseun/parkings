module ParkingSlots
  class Base < ::ApplicationInteraction

    def to_model
      parking_slot.reload
    end

    private

    # @overload role_params
    # @return [Hash]
    def parking_slot_params
      data = inputs.slice(:name, :archived)
      data[:parking_lot_id] = inputs[:parking_slot].parking_lot_id
      data
    end

    # This method checks if the current user role has permissions to update the parking slot name
    # @return [Hash]
    def validate_editable_title
      if parking_slot_params[:name].present?
        role = inputs[:role]
        unless role.super_admin? || role.town_manager?
          errors.add(:name, :unauthorized)
        end
      end
    end
  end
end
