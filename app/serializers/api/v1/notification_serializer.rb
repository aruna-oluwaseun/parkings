module Api
  module V1
    class NotificationSerializer < ::ApplicationSerializer
      attributes :id, :title, :text, :read, :created_at, :parking_session_id, 
                  :plate_number, :minutes_extended, :parking_slot_number, 
                  :violation_id, :violation_type, :citation_id, :wallet_remaining_ballance

      def read
        object.read?
      end

      def created_at
        object.created_at.to_i
      end

      def plate_number
        object.parking_session&.vehicle&.plate_number
      end

      def parking_slot_number
        object.parking_session&.parking_slot&.name
      end

      def violation_id
        object.violation&.id
      end
      
      def violation_type
        object.violation&.rule&.name
      end

      def citation_id
        object.violation&.citation_ticket&.id
      end

      def wallet_remaining_ballance
        object.user&.wallet&.amount
      end
      
    end
  end
end
