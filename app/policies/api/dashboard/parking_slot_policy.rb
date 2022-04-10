module Api
  module Dashboard
    class ParkingSlotPolicy < ::ApplicationPolicy

      def sessions?
        user.admin? || user.town_manager?
      end
    end
  end
end
