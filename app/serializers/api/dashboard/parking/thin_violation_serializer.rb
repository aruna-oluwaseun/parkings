module Api
  module Dashboard
    module Parking
      class ThinViolationSerializer < ::ApplicationSerializer
        attributes :id, :created_at, :violation_type, :agency

        def violation_type
          object.rule.name
        end

        def agency
          ThinAgencySerializer.new(object.ticket.agency)
        end
      end
    end
  end
end
