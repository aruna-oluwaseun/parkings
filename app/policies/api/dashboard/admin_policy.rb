module Api
  module Dashboard
    class AdminPolicy < ::ApplicationPolicy

      def update?
        super || record.id == user.id
      end
    end
  end
end
