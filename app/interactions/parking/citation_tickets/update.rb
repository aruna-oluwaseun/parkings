module Parking
  module CitationTickets
    class Update < ::Parking::Violations::Base
      object :object, class: 'Parking::CitationTicket'
      object :user, class: 'Admin'
      string :status
      string :plate_number, default: nil

      validate :validate_status_transaction, if: -> { user.officer? }

      def execute
        delete_images(object.violation)
        transactional_update!(object, inputs.slice(:status))
        transactional_update!(object.vehicle, inputs.slice(:plate_number)) if plate_number.present? && object.vehicle.present?
        save_images(object.violation) if images.any?
        update_parking_violation_status_to_close
      end

      private

      def validate_status_transaction
        current_status = object.status

        if current_status != 'unsettled' || status == 'sent_to_court'
          errors.add(:status, :transaction_not_allowed)
          throw(:abort)
        end
      end

      def update_parking_violation_status_to_close
        object.violation.ticket.closed! unless object.status == 'unsettled'
      end
    end
  end
end
