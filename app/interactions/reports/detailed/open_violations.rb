module Reports
    module Detailed
      # This class gives a place to put business logic to get data for rejected violations report
      class OpenViolations < Violations
        REPORT_NAME = 'Open Violations Report'.freeze

        # @return [Hash]
        def execute
          @pie_chart_scope = @pie_chart_parking_lots
                             .joins(violations: :citation_ticket)
                             .where('parking_violations.created_at': @pie_chart_date_range)
                             .where('parking_citation_tickets.status': Parking::CitationTicket.statuses[:unsettled])

          individual_parking_lot_scope = @individual_lots
                                         .includes(violations: [:citation_ticket, :rule])
                                         .where('parking_violations.created_at': @individual_lots_date_range)
                                         .where('parking_citation_tickets.status': Parking::CitationTicket.statuses[:unsettled])

          total_open_violations = { REPORT_NAME => @pie_chart_scope.size }

          {
            title: 'Open Violation Reports',
            pie_chart_data: pie_chart_violations_data,
            pie_chart_total: total_open_violations,
            parking_lots: individual_parking_lot_scope.map do |parking_lot|
              {
                id: parking_lot.id,
                name: parking_lot.name,
                bar_chart_data: total_daily_violations(parking_lot),
                table_data: parking_lot_table_data(parking_lot),
                total: total_daily_violations(parking_lot)[REPORT_NAME].values.sum
              }
            end
          }
        end

        # @overload pie_chart_violations_data
        # It groups parking lots by violation count
        # This method returns a hash to privide data to build pie chart
        # @example
        # { status: { "Parking Lot #0": 7, "Parking Lot #14": 1 } }
        # @return [Hash]
        def pie_chart_violations_data
          @pie_chart_violations_data ||= @pie_chart_scope
                                         .where('parking_citation_tickets.status': Parking::CitationTicket.statuses[:unsettled])
                                         .group('parking_lots.name').count
          { REPORT_NAME => @pie_chart_violations_data }
        end

        # @overload total_daily_violations(parking_lot)
        # This method returns hash to provide bar char data for each parking lot
        # This method groups parking lots violations by created at date field
        # @param [ParkingLot] parking_lot
        # example
        # { status: "18 Jun"=>4, "19 Jun" => 23 } }
        # @return [Hash]
        def total_daily_violations(parking_lot)
          @scope ||= parking_lot
                     .violations
                     .includes(:citation_ticket, :rule)
                     .where('parking_citation_tickets.status': Parking::CitationTicket.statuses[:unsettled])
                     .group("DATE_TRUNC('day', parking_violations.created_at)")
                     .count
          { REPORT_NAME => parse_date(@scope) }
        end
      end
    end
  end
