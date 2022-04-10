module Statistics
  # Historical number of vehicles that parked on the covered parking lots.
  # @example instantiate and execute as
  #   VehiclesParked.new(params).result
  class VehiclesParked < Base

    def execute
      Rails.cache.fetch("statistics/vehicles_parked/#{@parking_lots.map(&:id).join("-")}/#{@from.strftime("%m-%d-%y")}_#{@to.strftime("%m-%d-%y")}", expires_in: 20.minutes) do
        scope = ParkingSession.previous.where(parking_lot_id: @parking_lots.map(&:id))

        current_scope = scope.where(parked_at: @from..@to)

        {
          title: 'Vehicles Previously Parked',
          range_current_period: range_current_period,
          result: current_scope.count.zero? ? 'NO DATA' : "#{number_with_delimiter(current_scope.count)} Parked Before"
        }
      end
    end

    # @overload set_date_variables
    # This sets the date range.
    # the from, to, previous_from and previous_to are
    # used to scope the query on statistic resource
    #
    # This method is not meant to return a value but to set an instance variable.
    # Instance variable is used on Statistics classes that inherits this base class.
    # @return [void]
    def set_date_variables
      yesterday = (Time.now - 1.day)
      @from = yesterday.beginning_of_day
      @to = yesterday.end_of_day
      @range_label = :today

      if range && range.dig(:from).present? && range.dig(:to).present?
        @from = Time.zone.parse(range[:from]).utc.beginning_of_day
        @to = Time.zone.parse(range[:to]).utc.end_of_day

        # custom
        @range_label = :custom
        days_diff = (@to.to_date - @from.to_date).to_i
        @previous_from = (@from - days_diff.days).beginning_of_day
        @previous_to = (@to - days_diff.days).end_of_day
      end
    end

    # @overload range_current_period
    # It returns string for current selected daterange
    # @example the range_label is :custom it returns
    #   JUN/01-JUN/25
    # @example the range_label is :this_week, it returns
    #   This week
    # @example else if count is zero? it return
    #   NO DATA Last week
    # @return [String]
    def range_current_period
      if @range_label == :custom
        "#{@from.strftime("%^b/%d")}-#{@to.strftime("%^b/%d")}"
      else
        DATE_RANGE_LABELS[:today][:previous]
      end
    end

    # @overload set_parking_sessions disabling this method from base class
    # this statistics does not require
    # setting of parking sessions
    def set_parking_sessions; end
  end
end
