module Reports
  module Detailed
    # This class gives a place to put business logic to get data for rejected violations report
    class RejectedViolations < Violations
      REPORT_NAME = 'Rejected Violations'.freeze

      # @return [Hash]
      def execute
        @pie_chart_scope = @pie_chart_parking_lots
                           .joins(violations: :ticket)
                           .where('parking_violations.created_at': @pie_chart_date_range)
                           .where('parking_tickets.status': Parking::Ticket.statuses[:rejected])

        individual_parking_lot_scope = @individual_lots
                                       .includes(violations: [:ticket, :rule])
                                       .where('parking_violations.created_at': @individual_lots_date_range)
                                       .where('parking_tickets.status': Parking::Ticket.statuses[:rejected])

        total_rejected_violations = { REPORT_NAME => @pie_chart_scope.size }

        {
          title: 'Rejected Violation Reports',
          pie_chart_data: pie_chart_violations_data,
          pie_chart_total: total_rejected_violations,
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
                                       .where('parking_tickets.status': Parking::Ticket.statuses[:rejected])
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
                   .includes(:ticket, :rule)
                   .where('parking_tickets.status': Parking::Ticket.statuses[:rejected])
                   .group("DATE_TRUNC('day', parking_violations.created_at)")
                   .count
        { REPORT_NAME => parse_date(@scope) }
      end
    end
  end
end
