module Reports
  module Detailed
    # This class gives a place to put business logic to get data for revenues detailed report
    class Revenues < Base

      # @return [Hash]
      def execute
        @pie_chart_scope = @pie_chart_parking_lots
                           .joins(parking_sessions: :payments)
                           .select('parking_lots.id, parking_lots.name, SUM(amount) AS total_amount')
                           .where(payments: { status: Payment.statuses[:success] })
                           .where(payments: { created_at: @pie_chart_date_range })
                           .group('parking_lots.id')

        {
          title: 'Revenues Earned Reports',
          pie_chart_data: pie_chart_revenues_data
        }
      end

      private

      # @overload pie_chart_revenues_data
      # It groups parking lots by payment amount
      # This method returns a hash to privide data to build pie chart
      # @example
      # {
      #  'id': 1,
      #  'name': 'Parking Lot #0',
      #  'total_amount': '301.0'
      # }
      # @return [Hash]
      def pie_chart_revenues_data
        @pie_chart_scope.each_with_object([]) do |parking_lot, result|
          result << {
            id: parking_lot.id,
            name: parking_lot.name,
            total_amount: parking_lot.total_amount
          }
        end
      end

      def parking_lots
        @parking_lots ||= current_user.revenue_report_parking_lots
      end
    end
  end
end
