module Reports
  module Detailed
    # This class gives a place to put business logic to get data for detailed violation report
    class Violations < Base
      REPORT_STATUSES = Parking::CitationTicket.statuses.keys.freeze

      # @return [Hash]
      def execute
        @pie_chart_scope = @pie_chart_parking_lots
                           .joins(violations: :ticket)
                           .where('parking_violations.created_at': @pie_chart_date_range)

        @individual_parking_lot_scope = @individual_lots
                                        .includes(violations: [:citation_ticket, :rule])
                                        .where('parking_violations.created_at': @individual_lots_date_range)

        {
          title: 'Violation Reports',
          pie_chart_data: pie_chart_violations_data,
          pie_chart_total: pie_chart_total(pie_chart_violations_data),
          parking_lots: @individual_parking_lot_scope.map do |parking_lot|
            {
             id: parking_lot.id,
             name: parking_lot.name,
             bar_chart_data: daily_lot_violations(parking_lot),
             total: total_daily_violations(parking_lot),
             table_data: parking_lot_table_data(parking_lot)
            }
         end
        }
      end

      private

      # @overload pie_chart_violations_data
      # It groups parking lots by violation status
      # This method returns a hash to privide data to build pie chart
      # @example
      # {
      #   "open": { "Parking Lot #7": 6, "Parking Lot #2": 11 },
      #    "approved": {},
      #    "rejected": {},
      #    "close": {}
      # }
      # @return [Hash]
      def pie_chart_violations_data
        @pie_chart_violations_data ||= REPORT_STATUSES.each_with_object({}) do |status, result|
          result[I18n.t("interactions.reports.#{status}")] = @pie_chart_scope
                                                             .where('parking_tickets.status': Parking::Ticket.statuses[status])
                                                             .group('parking_lots.name').count
        end
      end

      # @overload daily_lot_violations(parking_lot)
      # This method returns parking lot violations count
      # @param [ParkingLot] parking_lot
      # @example
      # 20
      # @return [Integer]
      def daily_lot_violations(parking_lot)
        REPORT_STATUSES.each_with_object({}) do |status, result|
          scope = parking_lot
                  .violations
                  .includes([:ticket, :rule])
                  .where('parking_tickets.status': Parking::Ticket.statuses[status])
                  .group("DATE_TRUNC('day', parking_violations.created_at)")
                  .count
          result[I18n.t("interactions.reports.#{status}")] = parse_date(scope)
        end
      end

      # @overload total_daily_violations(parking_lot)
      # This method returns hash to provide bar chart data for each parking lot
      # This method groups parking lots violations by status and created at field
      # @param [ParkingLot] parking_lot
      # @example
      # {"open": { "22 Jun": 12 }, "approved": { "22 Jun": 4 } }
      # @return [Hash]
      def total_daily_violations(parking_lot)
        parking_lot
        .violations
        .where("parking_violations.created_at": @individual_lots_date_range)
        .count
      end

      # @overload parking_lot_table_data(parking_lot)
      # This method provide table data for each parking lot
      # @param [ParkingLot] parking_lot
      # @example
      #  [{:id=>3895, :date=>"18 Jun", :plate_number=>"approved", :voi_criteria=>"overlapping"}]
      # @return [Array]
      def parking_lot_table_data(parking_lot)
        parking_lot.violations.each_with_object([]) do |parking_violation, result|
          result << {
            id: parking_violation.id,
            date: parking_violation.created_at.to_date.strftime('%Y-%m-%d'),
            status: parking_violation&.citation_ticket&.status,
            voi_criteria: parking_violation&.rule&.name
          }
        end
      end
    end
  end
end
