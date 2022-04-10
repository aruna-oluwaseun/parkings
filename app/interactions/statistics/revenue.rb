module Statistics
  # Amount of parking fees collected from the covered parking lots.
  # @example instantiate and execute as
  #   Revenue.new(params).result
  class Revenue < Base
    def execute
      Rails.cache.fetch("statistics/revenue/#{@parking_lots.map(&:id).join("-")}/#{@from.strftime("%m-%d-%y")}_#{@to.strftime("%m-%d-%y")}", expires_in: 20.minutes) do
        scope = Payment.success.where(parking_session_id: @parking_session.map(&:id))

        previous_amount = scope.where(created_at: @previous_from..@previous_to).sum(&:amount_to_dollar)
        current_amount = scope.where(created_at: @from..@to).sum(&:amount_to_dollar)

        previous_amount = Payment::DEFAULT_AMOUNT if previous_amount.zero?
        current_amount = Payment::DEFAULT_AMOUNT if current_amount.zero?

        prev_amount = previous_amount.to_f > 0 ? previous_amount.to_f : 1
        percentage = (((current_amount-previous_amount)*100)/prev_amount.to_f)

        {
          title: 'Revenue Earned',
          range_current_period: range_current_period,
          result: current_amount.to_f.zero? ? 'NO DATA' : "#{current_amount.format} Parking Fees",
          compare_with_previous_period: {
            raise: percentage > 0,
            percentage: "#{number_with_delimiter(sprintf "%.2f", percentage.abs)}%"
          },
          result_previous_period: result_previous_period(previous_amount)
        }
      end
    end

    # @overload result_previous_period(amount)
    # It returns string for current selected daterange
    # @param [Integer, Float] amount
    # @example the range_label is :custom it returns
    #   'JUN/01-JUN/25'
    # @example the range_label is :this_week, it returns
    #   'Last week'
    # @example else if count is zero? it returns
    #   NO DATA from Last week
    # @return [String]
    def result_previous_period(amount)
      if @range_label == :custom
        "#{amount.to_f.zero? ? 'NO DATA' : amount.format} from #{@previous_from.strftime("%^b/%d")}-#{@previous_to.strftime("%^b/%d")}"
      else
        "#{amount.to_f.zero? ? 'NO DATA' : amount.format} from #{DATE_RANGE_LABELS[@range_label][:previous]}"
      end
    end

    def set_parking_lots
      parking_lots = current_user.revenue_report_parking_lots
      @parking_lots = parking_lot_ids.present? ? parking_lots.where(id: parking_lot_ids) : parking_lots
    end
  end
end
