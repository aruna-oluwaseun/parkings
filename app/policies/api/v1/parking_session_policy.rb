module Api
  module V1
    class ParkingSessionPolicy < ::ApplicationPolicy
      def extend?
        owner?
      end

      def payment?
        owner?
      end

      def confirm?
        owner?
      end

      def pay?
        owner?
      end

      def pay_later?
        owner?
      end

      def logs?
        user.admin?
      end

      private

      def owner?
        record.user.id == user.id
      end
    end
  end
end
