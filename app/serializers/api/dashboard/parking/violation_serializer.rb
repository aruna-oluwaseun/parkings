module Api
  module Dashboard
    module Parking
      class ViolationSerializer < ApplicationSerializer
        attributes :id,
                   :parking_ticket_id,
                   :status,
                   :created_at,
                   :violation_type,
                   :parking_lot,
                   :agency,
                   :officer,
                   :citation_ticket_id

        def parking_ticket_id
          object.ticket.id
        end

        def status
          I18n.t("activerecord.models.tickets.statuses.#{object.ticket.status}")
        end

        def violation_type
          I18n.t("activerecord.models.rules.description.#{object.rule.name}")
        end

        def parking_lot
          parking_lot = object.rule.lot
          {
            id: parking_lot.id,
            name: parking_lot.name
          }
        end

        def agency
          return unless agency = object.ticket&.agency

          {
            id: agency.id,
            name: agency.name
          }
        end

        def officer
          return unless officer = object.ticket&.admin

          {
            id: officer.id,
            name: officer.name,
            avatar: officer.avatar.attached? ? url_for(officer.avatar) : nil
          }
        end

        def citation_ticket_id
          object.citation_ticket&.id
        end
      end
    end
  end
end
