module Api
  module Dashboard
    module Parking
      class DetailedViolationSerializer < ViolationSerializer
        attributes :plate_number, :violation_photos, :history_logs

        def plate_number
          object&.session&.vehicle&.plate_number || object.plate_number
        end

        def violation_photos
          object.images.map do |image|
            {
              id: image.id,
              url: url_for(image.file),
            }
          end
        end

        def history_logs
          ::HistoryLogs::Violation.run({ violation_report: object }).result
        end

        has_many :comments, as: :subject, serializer: ::Api::Dashboard::CommentSerializer do
          object.comments
        end
      end
    end
  end
end
