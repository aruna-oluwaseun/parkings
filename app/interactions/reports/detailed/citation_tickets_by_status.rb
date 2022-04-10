module Reports
  module Detailed
    # This class gives a place to put business logic to get data for citation tickets report
    class CitationTicketsByStatus < Violations
      string :citation_ticket_status, default: nil

      REPORT_NAMES = I18n.t('interactions.reports.citation_tickets').with_indifferent_access

      # @return [Hash]
      def execute
        return {} unless REPORT_NAMES[citation_ticket_status]

        @pie_chart_scope = @pie_chart_parking_lots
                           .joins( :citation_tickets)
                           .where('parking_citation_tickets.created_at': @pie_chart_date_range)
                           .where('parking_citation_tickets.status': Parking::CitationTicket.statuses[citation_ticket_status])
        individual_parking_lot_scope = @individual_lots
                            .joins( :citation_tickets)
                            .where('parking_citation_tickets.created_at': @pie_chart_date_range)
                            .where('parking_citation_tickets.status': Parking::CitationTicket.statuses[citation_ticket_status])

        total_citation_tickets = { REPORT_NAMES[citation_ticket_status] => @pie_chart_scope.size }

        {
          title: "#{REPORT_NAMES[citation_ticket_status]} Reports",
          pie_chart_data: pie_chart_citation_tickets_data,
          pie_chart_total: total_citation_tickets,
          parking_lots: individual_parking_lot_scope.map do |parking_lot|
            {
              id: parking_lot.id,
              name: parking_lot.name,
              bar_chart_data: total_daily_citation_tickets(parking_lot),
              total: total_daily_citation_tickets(parking_lot)[REPORT_NAMES[citation_ticket_status]].values.sum
            }
          end
        }
      end

      # @overload pie_chart_citation_tickets_data
      # It groups parking lots by citation ticket count
      # This method returns a hash to provide data to build pie chart
      # @example
      # { Opened Citation Ticket: { "Parking Lot #0": 7, "Parking Lot #14": 1 } }
      # @return [Hash]
      def pie_chart_citation_tickets_data
        @pie_chart_citation_tickets_data ||= @pie_chart_scope
                                       .group('parking_lots.name').count
        { REPORT_NAMES[citation_ticket_status] => @pie_chart_citation_tickets_data }
      end

      # @overload total_daily_citation_tickets(parking_lot)
      # This method returns hash to provide bar char data for each parking lot
      # This method groups parking lot citation tickets by created at date field
      # @param [ParkingLot] parking_lot
      # example
      # { Opened Citation Ticket: "18 Jun"=>4, "19 Jun" => 23 } }
      # @return [Hash]
      def total_daily_citation_tickets(parking_lot_id)
        @scope ||= @parking_lots.where(id: parking_lot_id)
                   .joins(:citation_tickets)
                   .where('parking_citation_tickets.status': Parking::CitationTicket.statuses[citation_ticket_status])
                   .group("DATE_TRUNC('day', parking_citation_tickets.created_at)")
                   .count
        { REPORT_NAMES[citation_ticket_status] => parse_date(@scope) }
      end
    end
  end
end
