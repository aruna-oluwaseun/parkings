module Api
  module Dashboard
    module Parking
      class CitationTicketSerializer < ::ApplicationSerializer
        attributes :id,
                   :violation_id,
                   :status,
                   :violation_type,
                   :parking_lot,
                   :created_at,
                   :plate_number,
                   :officer,
                   :violation_photos,
                   :history_logs

        def violation_type
          I18n.t("activerecord.models.rules.description.#{object.violation.rule.name}")
        end

        def status
          I18n.t("activerecord.models.parking/citation_tickets.statuses.#{object.status}")
        end

        def parking_lot
          {
            id: object.violation.rule.lot.id,
            name: object.violation.rule.lot.name
          }
        end

        def plate_number
          object.violation.vehicle_rule&.vehicle&.plate_number&.upcase || object.violation.plate_number&.upcase
        end

        def violation_photos
          object.violation.images.map do|image|
            {
              id: image.id,
              url: url_for(image.file)
            }
          end
        end

        def history_logs
          ::HistoryLogs::CitationTicket.run(citation_ticket: object).result
        end

        def officer
          return unless officer = object.violation.ticket&.admin

          {
            id: officer.id,
            name: officer.name,
            avatar: officer.avatar.attached? ? url_for(officer.avatar) : nil
          }
        end

        has_many :comments, as: :subject, serializer: ::Api::Dashboard::CommentSerializer do
          object.comments
        end
      end
    end
  end
end
