module Statistics
  # @example instantiate and execute as
  #   VehiclesCurrentlyParked.new(params).result
  class VehiclesCurrentlyParked < Base
    def execute
      todays_scope = ParkingSession.current.where(parking_lot_id: @parking_lots.map(&:id))

      {
        title: I18n.t('interactions.statistics.currently_parked'),
        disable_date_range: true,
        range_current_period: range_current_period,
        result: I18n.t('interactions.statistics.parked_now', count: number_with_delimiter(todays_scope.count))
      }
    end

    # @overload set_parking_sessions disabling this method from base class
    # this statistics does not require
    # setting of parking sessions
    def set_parking_sessions; end
  end
end
