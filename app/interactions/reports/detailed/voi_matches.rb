module Reports
  module Detailed
    # This class gives a place to put business logic to get data for detailed voi matches report
    class VoiMatches < Base
      REPORT_NAME = 'Voi Matches'.freeze

      # @return [Hash]
      def execute
        pie_chart_scope = ::Parking::VehicleRule
                           .joins(:lot)
                           .active
                           .where(created_at: @pie_chart_date_range)
                           .where(lot_id: @pie_chart_parking_lots.ids)

        voi_matches_pie_chart_data = { REPORT_NAME => pie_chart_scope.group('parking_lots.name').count }

        total_voi_matches = { REPORT_NAME => pie_chart_scope.size }

        @individual_lot_voi_matches = ::Parking::VehicleRule
                                       .active
                                       .includes(:lot, :vehicle, violation: :rule)
                                       .where(lot_id: @individual_lots.ids)
                                       .where(created_at: @individual_lots_date_range)

        individual_parking_lots = @individual_lot_voi_matches.map(&:lot).uniq

        {
          title: 'VOI Matches Report',
          pie_chart_data: voi_matches_pie_chart_data,
          pie_chart_total: total_voi_matches,
          parking_lots: individual_parking_lots.map do |parking_lot|
            {
              id: parking_lot.id,
              name: parking_lot.name,
              bar_chart_data: daily_lot_voi_matches(parking_lot.id),
              table_data: parking_lot_table_data(parking_lot.id),
              total: daily_lot_voi_matches(parking_lot.id)[REPORT_NAME].values.sum
            }
          end
        }
      end

      private
      # @overload daily_lot_voi_matches(lot_id)
      # This method returns hash to provide bar char data for each parking lot
      # This method groups parking lots voi mathces by created at date
      # @param [Integer] lot_id
      # @example
      #  { status: {"18 Jun"=>4, "19 Jun" => 23 } }
      # @return [Hash]
      def daily_lot_voi_matches(lot_id)
        @scope ||= @individual_lot_voi_matches
                    .where(lot_id: lot_id)
                    .group("DATE_TRUNC('day', parking_vehicle_rules.created_at)")
                    .count
        { REPORT_NAME => parse_date(@scope) }
      end

      # @overload parking_lot_table_data(lot_id)
      # This method provide table data for each parking lot
      # @param [Integer] lot_id
      # @example
      #   [{:id=>3895, :date=>"18 Jun", :plate_number=>"123abc", :voi_criteria=>"overlapping"}]
      # @return [Array]
      def parking_lot_table_data(lot_id)
        @individual_lot_voi_matches.where(lot_id: lot_id).each_with_object([]) do |voi_match, result|
          result << {
            id: voi_match.id,
            date: voi_match.created_at.to_date.strftime('%Y-%m-%d'),
            plate_number: voi_match.vehicle&.plate_number,
            voi_criteria: voi_match.violation&.rule&.name
          }
        end
      end
    end
  end
end
