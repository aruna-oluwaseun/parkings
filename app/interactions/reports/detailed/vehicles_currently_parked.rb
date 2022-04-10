module Reports
  module Detailed
    # This class gives a place to put business logic to get data for vehicle currently parked report
    class VehiclesCurrentlyParked < Base
      REPORT_NAME = 'Vehicles Currently Parked'.freeze
      def execute
        @pie_chart_scope = @pie_chart_parking_lots.joins(:parking_sessions).where('parking_sessions.created_at': @pie_chart_date_range)
        total_vehicles_currently_parked = { REPORT_NAME => @pie_chart_scope.size }

        {
          title: 'Vehicles Currently Parked Reports',
          pie_chart_data: pie_chart_vehicles_currently_parked_data,
          pie_chart_total: total_vehicles_currently_parked,
        }
      end

      def pie_chart_vehicles_currently_parked_data
        @pie_chart_vehicles_currently_parked_data ||= @pie_chart_scope
                                       .group('parking_lots.name').count
        { REPORT_NAME => @pie_chart_vehicles_currently_parked_data }
      end
    end
  end
end
