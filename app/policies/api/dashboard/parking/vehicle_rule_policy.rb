module Api
  module Dashboard
    module Parking
      class VehicleRulePolicy < ::ApplicationPolicy

        def archive?
          record_is_permissable? ?
          permission.update? : true
        end
      end
    end
  end
end
