module Parking
  module CitationTickets
    # This class gives a place to put business logic to create citation ticket
    class Create < ApplicationInteraction
      attr_reader :citation_ticket

      # @return [Parking::CitationTickets::Create]
      def execute
        Parking::CitationTicket.transaction do
          payload = citation_ticket.fetch(:parking_violation, {})
          @result = ::Parking::Violations::Create.run(payload)
          if @result.valid?
            citation_ticket = create_citation_ticket
            Dashboard::Parking::UpdateCitationTicketStatusWorker.sent_to_court(citation_ticket)
            citation_ticket
          else
            @result
          end
        end
      end

      private

      # @overload create_citation_ticket
      # This method creates citation ticket
      # @return [Parking::CitationTicket]
      def create_citation_ticket
        transactional_create!(Parking::CitationTicket, citation_ticket_params)
      end

      # @overload citation_ticket_params
      # This method builds citation ticket params
      # example
      # { status: "settled", violation_id: 3 }
      # @return [Hash]
      def citation_ticket_params
        citation_ticket.permit(:status).merge(violation_id: @result.object.id)
      end
    end
  end
end
