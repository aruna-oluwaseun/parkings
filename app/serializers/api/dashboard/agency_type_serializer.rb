module Api
  module Dashboard
    class AgencyTypeSerializer < ::ApplicationSerializer
      attributes :id, :name, :removable

      def removable
        object.can_deleted?
      end
    end
  end
end
