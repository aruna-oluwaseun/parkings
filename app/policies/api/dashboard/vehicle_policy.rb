module Api
  module Dashboard
    class VehiclePolicy < ::ApplicationPolicy
      def index?
        super || user.town_manager
      end

      def active?
        super || user.town_manager
      end

      def inactive?
        super || user.town_manager
      end

      def rejected?
        super || user.town_manager
      end

      def show?
        super || user.town_manager?
      end
    end
  end
end
