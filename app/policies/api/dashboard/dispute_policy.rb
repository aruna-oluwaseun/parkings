module Api
  module Dashboard
    class DisputePolicy < ::ApplicationPolicy

      def show?
        super && record_related?
      end

      private

      def record_related?
        return true if super_admin?
        return false unless town_manager?
        record.parking_session.parking_lot
        Admin::Right.where(
          subject_type: 'ParkingLot',
          subject_id: record.parking_session.parking_lot.id,
          admin_id: user.id
        ).any?
      end
    end
  end
end
