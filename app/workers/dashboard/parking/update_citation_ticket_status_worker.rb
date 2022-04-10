module Dashboard
  module Parking
    class UpdateCitationTicketStatusWorker

      include Sidekiq::Worker
      sidekiq_options queue: :ai

      def perform(citation_ticket_id)
        citation_ticket = ::Parking::CitationTicket.find_by(id: citation_ticket_id)
        return unless citation_ticket
        return unless citation_ticket.status == 'unsettled'

        ::Parking::CitationTicket.transaction do
          citation_ticket.update(status: :sent_to_court)
          citation_ticket.violation.ticket.update(status: :closed)
        end
      end

      def self.sent_to_court(citation_ticket)
        Sidekiq::ScheduledSet.new.each do |job|
          next if job.klass != self.name
          next if job.args.exclude?(citation_ticket)
          job.delete
        end

        duration = ::Parking::Setting.find_by(subject_type: 'ParkingLot' )

        perform_at(duration.court_duration.day.from_now.freeze, citation_ticket.id)
      end
    end
  end
end
