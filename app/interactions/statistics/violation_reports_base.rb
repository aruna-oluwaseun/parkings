module Statistics
  # @example instantiate and execute as
  #   ViolationReportsBase.new(params).result
  class ViolationReportsBase < Base
    set_callback :execute, :before, -> do
      set_parking_ticket_variables
    end

    def execute

      parking_lot_ids = @parking_lots.map(&:id).join("-")
      cache_date = "#{@from.strftime('%m-%d-%y')}_#{@to.strftime('%m-%d-%y')}"

      Rails.cache.fetch("statistics/violation_commited/#{parking_lot_ids}/#{cache_date}/#{@status}", expires_in: CACHE_EXPIRE_TIME) do
        scope = ::Parking::Violation.send(@status.to_sym).with_role_condition(current_user).by_parking_lot_ids(@parking_lots.map(&:id))
        current_scope = scope.where(created_at: @from..@to)
        previous_scope = scope.where(created_at: @previous_from..@previous_to)

        prev_count = previous_scope.count > 0 ? previous_scope.count : 1
        percentage = (((current_scope.count-previous_scope.count)*100)/prev_count.to_f)

        {
          title: @title,
          range_current_period: range_current_period,
          result: current_scope.count.zero? ? 'NO DATA' : "#{number_with_delimiter(current_scope.count)} #{@data_label}",
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
