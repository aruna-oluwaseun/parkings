module Api
  module Dashboard
    class CommentPolicy < ApplicationPolicy
      # NOTE mock policy bcs Comment model should be merged with Message soon
      def index?
        true || permission.read?
      end

      def create?
        true || permission.create?
      end

      def update?
        (true || permission.update?) && (record.admin_id == user.id)
      end

      def destroy?
        (true || permission.delete?) && (record.admin_id == user.id)
      end
    end
  end
end
