module Api
  module Dashboard
    class PaymentPolicy < ::ApplicationPolicy
      def index?
        super_admin? || town_manager?
      end

      def show?
        super
      end
    end
  end
end
