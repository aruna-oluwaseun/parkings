module Parking
  module Violations
    class Update < Base
      object :object, class: 'Parking::Violation'
      object :user, class: 'Admin'
      string :status
      integer :admin_id, default: nil
      string :violation_type, default: nil

      attr_reader :current_status

      validate :validate_status_transaction, if: -> { user.officer? }

      set_callback :execute, :before, -> do
        @current_status = object.ticket.status
      end

      def execute
        delete_images(object)
        transactional_update!(object.ticket, ticket_params)
        transactional_update!(object.rule, { name: violation_type }) if violation_type
        save_images(object) if images.any?
        create_citation_ticket
      end

      private

      def ticket_params
        inputs.slice(:status, :admin_id)
      end

      def validate_status_transaction
        return if current_status == status

        unless current_status == 'opened' && ['approved', 'canceled'].include?(status)
          errors.add(:status, :transaction_not_allowed)
          throw(:abort)
        end
      end

      # @overload create_citation_ticket
      # This method creates citation ticket with related parking ticket object
      # @return [Boolean]
      def create_citation_ticket
        if current_status == 'opened' && object.ticket.status == 'approved'
          transactional_create!(Parking::CitationTicket, citation_ticket_params)
        end
      end

      # @overload citation_ticket_params
      # This method prepares citation ticket params based on a parking violation
      # example
      # { "violation_id"=>327 }
      # @return [Hash]
      def citation_ticket_params
        { violation_id: object.id }
      end
    end
  end
end
