module Agencies
  class Base < ::ApplicationInteraction
    attr_reader :manager, :officers, :agency_type

    object :current_user, class: Admin
    array :parking_lot_ids, default: [] do
      integer
    end

    def to_model
      agency.reload
    end

    private

    def agency_params
      data = inputs.slice(:email, :name, :status, :phone, :agency_type_id)
      data[:avatar] = { data: inputs[:avatar] } if inputs[:avatar].present?
      data
    end

    def location_params
      location&.slice(:lng, :ltd, :city, :country, :state, :street, :zip, :building)
    end

    def validate_manager
      unless @manager = Admin.manager.find_by(id: manager_id)
        errors.add(:manager_id, :not_found)
        throw(:abort)
      end
    end

    def validate_officers
      @officers = Admin.officer.where(id: officer_ids)
      unless officers.count > 0
        errors.add(:officer_ids, :not_found)
        throw(:abort)
      end
    end

    def parking_lots
      ParkingLot.where(id: parking_lot_ids)
    end

    def validate_agency_type
      unless @agency_type = AgencyType.find_by(id: agency_type_id)
        errors.add(:agency_type_id, :not_found)
        throw(:abort)
      end
    end
    
  end
end
