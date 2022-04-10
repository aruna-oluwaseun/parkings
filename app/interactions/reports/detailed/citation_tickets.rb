module Reports
  module Detailed
    # This class gives a place to put business logic to get data for citation tickets report
    class CitationTickets < Violations
      CITATION_TICKET_STATUSES = [:unsettled, :settled, :canceled, :sent_to_court].freeze
      CITATION_TICKET_STATUS_VALUES = CITATION_TICKET_STATUSES.map { |status| Parking::CitationTicket.statuses[status] }.freeze

      def execute
        @pie_chart_scope = @pie_chart_parking_lots
                          .joins(:violations, :citation_tickets)
                          .where('parking_citation_tickets.status': CITATION_TICKET_STATUS_VALUES)
                          .where('parking_violations.created_at': @pie_chart_date_range)

        @individual_parking_lot_scope = @individual_lots
                                        .joins(:violations, :citation_tickets)
                                        .where('parking_citation_tickets.status': CITATION_TICKET_STATUS_VALUES)
                                        .where('parking_violations.created_at': @pie_chart_date_range)
        {
          title: 'Citation Ticket Reports',
          pie_chart_data: pie_chart_citation_tickets_data,
          pie_chart_total:pie_chart_total(pie_chart_citation_tickets_data),
          parking_lots: @individual_parking_lot_scope.map do |parking_lot|
            {
              id: parking_lot.id,
              name: parking_lot.name,
              bar_chart_data: daily_lot_citation_tickets(parking_lot),
              total: total_daily_violations(parking_lot),
              table_data: parking_lot_table_data(parking_lot)
            }
          end
        }
      end

      # @overload pie_chart_citation_tickets_data
      # It groups parking lots by citation ticket status
      # This method returns a hash of data to build pie chart
      # @example
      # {
      #   "Unsettled citation tickets": { "Parking Lot #7": 6, "Parking Lot #2": 11 },
      #"  "Resolved citation tickets": { "Parking Lot #2": 4 },
      #   "Canceled citation tickets": {},
      #   "Sent to court citation tickets": {}
      # }
      # @return [Hash]
      def pie_chart_citation_tickets_data
        @pie_chart_citations_tickets_data ||= CITATION_TICKET_STATUSES .each_with_object({}) do |status, result|
          result[I18n.t("interactions.reports.citation_tickets.#{status}")] = @pie_chart_scope
                                                                              .group('parking_lots.name').count
        end
      end

      # @overload daily_lot_citation_tickets(parking_lot))
      # This method returns parking lot citation tickets count
      # @param [ParkingLot] parking_lot
      # @example
      # {
      #  "Unsettled citation tickets" => { "2020-06-01" => 4, "2020-06-02" => 1 },
      #  "Resolved citation tickets"=> { "2020-06-01" => 2, "2020-06-07" => 6 },
      #  "Canceled citation tickets": {},
      #  "Sent to court citation tickets": { "2020-06-01" => 2, "2020-06-07" => 6 }
      # }
      # @return [Hash]
      def daily_lot_citation_tickets(parking_lot)
        CITATION_TICKET_STATUSES.each_with_object({}) do |status, result|
          scope = parking_lot
                  .violations
                  .includes([:ticket, :rule])
                  .where('parking_citation_tickets.status': Parking::CitationTicket.statuses[status])
                  .group("DATE_TRUNC('day', parking_violations.created_at)")
                  .count
          result[I18n.t("interactions.reports.citation_tickets.#{status}")] = parse_date(scope)
        end
      end
    end
  end
end
