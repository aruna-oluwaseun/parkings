module Api
  module Dashboard
    class ParkingLotPolicy < ::ApplicationPolicy

      def update?
        super && record_related?
      end

      def show?
        super && record_related?
      end

      private

      # This method is a extra validation for predefined roles
      # If the user has a predefined role, we need to check if it is a parking admin or town manager.
      # parking admin can manage only his parking lot (partial permission), admin and town manager can view all (full permission)
      # this function can be ignored if the user role it's not a predefined role. In that scenario, we directly return true
      # @return [Boolean]
      def record_related?
        return true if super_admin?
        if user.with_predefined_role?
          Admin::Right.where(
            subject_type: 'ParkingLot',
            subject_id: record.id,
            admin_id: user.id
          ).any?
        end
      end
    end
  end
end
