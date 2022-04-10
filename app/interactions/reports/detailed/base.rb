module Reports
  module Detailed
    class Base < ::ApplicationInteraction
      include ActionView::Helpers::NumberHelper

      object :current_user, class: Admin
      string :violation_status, default: nil
      hash :pie_chart, default: {} do
        array :parking_lot_ids, default: [] do
          integer
        end
        hash :range, strip: false, default: nil
      end
      hash :individual_lots, default: {} do
        array :parking_lot_ids, default: [] do
          integer
        end
        hash :range, strip: false, default: nil
      end

      set_callback :execute, :before, -> do
        set_pie_chart_variables
        set_individual_lots_variables
      end

      def date_today_range
        @date_today ||= Time.zone.now.beginning_of_day..Time.zone.now.end_of_day
      end

      def pie_chart_date_range
        return date_today_range if pie_chart.dig(:range, :from).blank? || pie_chart.dig(:range, :to).blank?

        from = Time.zone.parse(pie_chart[:range][:from])
        to = pie_chart[:range][:to].blank? ? from.end_of_day : Time.zone.parse(pie_chart[:range][:to]).end_of_day
        from..to
      end

      def pie_chart_lots
        pie_chart[:parking_lot_ids].blank? ? parking_lots : parking_lots.where(id: pie_chart[:parking_lot_ids])
      end

      def set_pie_chart_variables
        @pie_chart_date_range = pie_chart_date_range
        @pie_chart_parking_lots = pie_chart_lots
      end

      def individual_lots_date_range
        return date_today_range if individual_lots.dig(:range, :from).blank? || individual_lots.dig(:range, :to).blank?

        from = Time.zone.parse(individual_lots[:range][:from])
        to = individual_lots[:range][:to].blank? ? from.end_of_day : Time.zone.parse(individual_lots[:range][:to]).end_of_day
        from..to
      end

      def individual_parking_lots
        individual_lots[:parking_lot_ids].blank? ? parking_lots : parking_lots.where(id: individual_lots[:parking_lot_ids])
      end

      def set_individual_lots_variables
        @individual_lots_date_range = individual_lots_date_range
        @individual_lots = individual_parking_lots
      end

      def parking_lots
        @parking_lots ||= current_user.available_parking_lots
      end

      def parse_date(scope)
        scope.map { |date, count| { date.strftime('%Y-%m-%d') => count } }.reduce({}, :merge)
      end

      # @overload pie_chart_total
      # This method returns total parking lots violations grouped by it status
      # @example
      # { "open": 15, "approved": 15, "rejected": 0, "close": 0 }
      # @return [Hash]
      def pie_chart_total(pie_chart_data)
        pie_chart_data.map { |status, violations| { status => violations.values.sum } }.reduce({}, :merge)
      end
    end
  end
end
