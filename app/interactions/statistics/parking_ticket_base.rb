module Statistics
  # @example instantiate and execute as
  #   ParkingTicketsSettled.new(params).result
  class ParkingTicketBase < Base
    set_callback :execute, :before, -> do
      set_parking_ticket_variables
    end

    # @return [Hash]
    def execute
      Rails.cache.fetch("statistics/parking_tickets/#{@parking_lots.map(&:id).join("-")}/#{@from.strftime("%m-%d-%y")}_#{@to.strftime("%m-%d-%y")}/#{@status}", expires_in: 20.minutes) do
        scope = ::Parking::Ticket.send(@status.to_sym).by_parking_lot_ids(@parking_lots.map(&:id)).where(status: @status)

        current_scope = scope.where(created_at: @from..@to)
        previous_scope = scope.where(created_at: @previous_from..@previous_to)

        previous_count = previous_scope.count > 0 ? previous_scope.count : 1
        percentage = (((current_scope.count-previous_scope.count)*100)/previous_count.to_f)

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
