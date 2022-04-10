module Api
  module Dashboard
    module Parking
      class ThinCitationTicketSerializer < ::ApplicationSerializer
        attributes :id, :status, :created_at

        def status
          I18n.t("activerecord.models.parking/citation_tickets.statuses.#{object.status}")
        end
      end
    end
  end
end
