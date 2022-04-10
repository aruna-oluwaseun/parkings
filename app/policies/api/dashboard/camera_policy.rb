module Api
  module Dashboard
    class CameraPolicy < ::ApplicationPolicy
      def show?
        user.available_parking_lots.find_by(id: record.parking_lot).present?
      end

      def update?
        super && record_related?
      end

      def destroy?
        super && record_related?
      end

      private

      # This method is a extra validation for predefined roles
      # If the user has a predefined role, we need to check if it is a parking admin or town manager.
      # Parking admin can manage the streaming of his parking lot (partial permission), town manager and admin can view all (full permission)
      # This function can be ignored if the user role it's not a predefined role. In that scenario, we directly return true
      # @return [Boolean]
      def record_related?
        return true if super_admin?
        if user.with_predefined_role?
          Admin::Right.where(
            subject_type: 'ParkingLot',
            subject_id: record.parking_lot.id,
            admin_id: user.id
          ).any?
        end
      end
    end
  end
end
