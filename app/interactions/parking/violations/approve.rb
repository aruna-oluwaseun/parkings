module Parking
  module Violations
    # This class gives a place to put business logic to update parking violation status
    class Approve < ApplicationInteraction
      object :object, class: Parking::Violation

      # @return [Parking::Violations::Approve]
      def execute
        Parking::Violation.transaction do
          update_parking_violation
          create_citation_ticket
        end
      end

      private

      # @overload update_parking_violation
      # This method updates violation ticket status
      # @return [Boolean]
      def update_parking_violation
        transactional_update!(object.ticket, status: Parking::Ticket.statuses[:approved])
      end

      # @overload create_citation_ticket
      # This method creates citation ticket with related parking ticket object
      # @return [Boolean]
      def create_citation_ticket
        transactional_create!(Parking::CitationTicket, citation_ticket_params)
      end

      # @overload citation_ticket_params
      # This method prepares citation ticket params based on a parking violation
      # example
      # { "description"=>"some description","violation_id"=>327 }
      # @return [Hash]
      def citation_ticket_params
        { description: object.description, violation_id: object.id }
      end
    end
  end
end
