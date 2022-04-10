module Api
  module Dashboard
    class Parking::RulePolicy < ::ApplicationPolicy
      def update?
        user.admin? || record_related?
      end

      private

      # This method is a extra validation for predefined roles
      # If the user has a predefined role, we need to check if it is a parking admin or town manager.
      # This function can be ignored if the user role it's not a predefined role. In that scenario, we directly return true
      # @return [Boolean]
      def record_related?
        if user.with_predefined_role?
          Admin::Right.where(
            subject_type: 'ParkingLot',
            subject_id: record.lot.id,
            admin_id: user.id
          ).any?
        else
          true
        end
      end
    end
  end
end
