module ParkingLots
  class Base < ::ApplicationInteraction
    attr_reader :admin, :manager

    private

    def validate_admin
      unless @admin = Admin.active.parking_admin.find_by(id: parking_admin_id)
        errors.add(:parking_admin_id, :not_found)
        throw(:abort)
      end
    end

    def validate_manager
      unless @manager = Admin.town_manager.active.find_by(id: town_manager_id)
        errors.add(:town_manager_id, :not_found)
        throw(:abort)
      end
    end

    def setting_params
      setting.slice(:free, :parked, :rate, :overtime, :period, :incremental)
    end

    def parking_lot_params
      data = inputs.slice(:name, :email, :phone, :status, :outline, :agency_id)
      data[:avatar] = { data: inputs[:avatar] } if inputs[:avatar].present?
      data
    end

    def location_params
      location&.slice(:lng, :ltd, :city, :country, :state, :street, :zip, :building)
    end

    def save_places(parking_lot)
      ::Dashboard::Redis::SaveParkingLotPlaces.call(parking_lot)
    end
  end
end
