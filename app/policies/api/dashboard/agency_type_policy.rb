module Api
  module Dashboard
    class AgencyTypePolicy < ::ApplicationPolicy
      def index?
        user.admin?
      end

      def create?
        user.admin?
      end

      def update?
        create?
      end

      def show?
        index?
      end

      def destroy?
        create?
      end
    end
  end
end
