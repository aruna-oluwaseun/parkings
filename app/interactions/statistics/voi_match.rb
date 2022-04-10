module Statistics
  # Vehicle of Interest(VOI) that are detected inside covered parking lots.
  # @example instantiate and execute as
  #   VoiMatch.new(params).result
  class VoiMatch < Base

    def execute
      Rails.cache.fetch("statistics/vio_match/#{@parking_lots.map(&:id).join("-")}/#{@from.strftime("%m-%d-%y")}_#{@to.strftime("%m-%d-%y")}", expires_in: 20.minutes) do
        scope = ::Parking::VehicleRule.active.where(lot_id: @parking_lots.map(&:id))

        current_scope = scope.where(created_at: @from..@to)
        previous_scope = scope.where(created_at: @previous_from..@previous_to)

        previous_count = previous_scope.count > 0 ? previous_scope.count : 1
        percentage = (((current_scope.count-previous_scope.count)*100)/previous_count.to_f)

        {
          title: 'Vehicle of Interest Match',
          range_current_period: range_current_period,
          result: "#{number_with_delimiter(current_scope.count)} VOI Matched",
          compare_with_previous_period: {
            raise: percentage > 0,
            percentage: "#{number_with_delimiter(sprintf "%.2f", percentage.abs)}%"
          },
          result_previous_period: result_previous_period(number_with_delimiter(previous_scope.count))
        }
      end
    end

  end
end
