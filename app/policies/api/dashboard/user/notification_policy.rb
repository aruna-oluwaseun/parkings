module Api
  module Dashboard
    class User::NotificationPolicy < ::ApplicationPolicy
      def update?
        user.super_admin?
      end

      def show?
        user.super_admin?
      end
    end
  end
end
