module Api
  module Dashboard
    class DetailedUserSerializer < UserSerializer
      attributes :avatar, :phone, :role_type, :parking_lot_ids, :agency_id, :associated_parking_lots

      has_one :role, serializer: RoleSerializer

      def avatar
        rails_blob_url(object.avatar) if object.avatar.attached?
      end

      def associated_parking_lots
        return [] unless object.officer? || object.manager?
        rights = Admin::Right.where(subject_type: 'Agency', admin_id: object.id)
        ParkingLot.where(agency_id: rights.pluck(:subject_id)).select(:id, :name).map do |parking_lot|
          { id: parking_lot.id, name: parking_lot.name }
        end
      end

      def parking_lot_ids
        rights = ::Admin::Right.where(subject_type: 'ParkingLot', admin_id: object.id)
        rights.map(&:subject_id)
      end

      def agency_id
        if object.agency_manager? || object.agency_officer?
          rights = ::Admin::Right.where(subject_type: 'Agency', admin_id: object.id)
          rights.map(&:subject_id).last
        end
      end

      def role_type
        if object.super_admin?
          :super_admin
        elsif object.agency_manager?
          :agency_manager
        elsif object.agency_officer?
          :agency_officer
        elsif object.parking_admin?
          :parking_lot_manager
        elsif object.town_manager?
          :town_manager
        end
      end
      
    end
  end
end
