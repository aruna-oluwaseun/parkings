module Api
  module Dashboard
    class NotificationSerializer < ::ApplicationSerializer
      attributes :id, :user_id, :title, :text, :type, :status, :created_at, :parking_session_id, :plate_number
      belongs_to :user, serializer: ThinUserSerializer
      belongs_to :parking_session, serializer: ParkingSessionSerializer

      def type
        object.template
      end

      def plate_number
        object.parking_session&.vehicle&.plate_number
      end
    end
  end
end
