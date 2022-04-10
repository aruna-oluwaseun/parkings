module Api
  module Dashboard
    class ThinRoleSerializer < ApplicationSerializer
      attributes :id, :name

      def name
        object.display_name
      end
    end
  end
end
