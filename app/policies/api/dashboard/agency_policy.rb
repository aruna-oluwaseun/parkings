module Api
  module Dashboard
    class AgencyPolicy < ::ApplicationPolicy
      def create?
        user.admin?
      end

      def show?
        record_related? || user_related_parking_lot?
      end

      def update?
        (record_related? || user_related_parking_lot?) &&
        !user.officer?
      end

      def destroy?
        user.admin?
      end

      private

      def record_related?
        return true if super_admin?
        if user.with_predefined_role?
          Admin::Right.where(
            subject_type: 'Agency',
            subject_id: record.id,
            admin_id: user.id
          ).any?
        end
      end

      def user_related_parking_lot?
        return true if super_admin?
        if user.with_predefined_role?
          Admin::Right.where(
            subject_type: 'ParkingLot',
            subject_id: ParkingLot.where(agency_id: record.id).select(:id).pluck(:id),
            admin_id: user.id
          ).any?
        end
      end
    end
  end
end
