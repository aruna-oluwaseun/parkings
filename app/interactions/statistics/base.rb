module Statistics
  # @abstact This class is will be inherit by different statistic classes.
  class Base < ::ApplicationInteraction
    include ActionView::Helpers::NumberHelper
    DATE_RANGE_LABELS = {
      today: {
        current: 'Today',
        previous: 'Yesterday'
      },
      week: {
        current: 'This week',
        previous: 'Last week'
      },
      month: {
        current: 'This month',
        previous: 'Last month'
      }
    }.freeze

    CACHE_EXPIRE_TIME = 20.minutes

    # @attr [Object] current_user defines the current user
    object :current_user, class: Admin

    # @attr [Array] parking_lot_ids listing of parking_lot_ids to scope queries
    # @options parking_lot_ids [Array<String>, EmptyArray]
    array :parking_lot_ids, default: [] do
      integer
    end

    # @attr [Hash] range defines date range to scope queries
    # @options range [string] :from datestring
    # @options range [string] :to datestring
    hash :range, strip: false, default: nil

    set_callback :execute, :before, -> do
      set_parking_lots
      set_date_variables
      set_parking_sessions
    end

    # @overload set_parking_lots
    # It sets the parking list accessible by the current user
    # unless @param :parking_lot_ids is supplied
    #
    # This method is not meant to return a value but to set an instance variable.
    # Instance variable is used on Statistics classes that inherits this base class.
    # @return [ParkingLot::ActiveRecord_AssociationRelation, ParkingLot::ActiveRecord_Associations_CollectionProxy]
    def set_parking_lots
      lots = if current_user.town_manager? || current_user.super_admin?
               ParkingLot.all
             else
               current_user.available_parking_lots
             end
      @parking_lots = parking_lot_ids.present? ? lots.where(id: parking_lot_ids) : lots
    end

    # @overload set_parking_sessions
    # It sets the parking sessions based on the current selected parking lots
    # This is used on some statistics to scope the query
    #
    # This method is not meant to return a value but to set an instance variable.
    # Instance variable is used on Statistics classes that inherits this base class.
    # @return [void]
    def set_parking_sessions
      @parking_session = ParkingSession.where(
        parking_lot_id: @parking_lots.map(&:id),
        created_at: @previous_from..@to
      )
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
      today = Time.now.in_time_zone(current_time_zone).utc.beginning_of_day

      # default today
      range_label = :today
      from = today.beginning_of_day
      to = today.end_of_day
      previous_from = from - 1.day
      previous_to = to - 1.day

      if range && range.dig(:from).present? && range.dig(:to).present?
        from = Time.zone.local_to_utc(range[:from].to_time).beginning_of_day
        to = Time.zone.local_to_utc(range[:to].to_time).end_of_day

        # custom
        range_label = :custom
        days_diff = (to.to_date - from.to_date).to_i
        previous_from = (from - days_diff.days).beginning_of_day
        previous_to = (to - days_diff.days).end_of_day

        # month
        if (from == today.beginning_of_month) &&
           (to == today.end_of_month)
          range_label = :month
          previous_from = (from - 1.month).beginning_of_month
          previous_to = (to - 1.month).end_of_month
        end

        # week
        if (from == today.beginning_of_week) &&
            (to == today.end_of_week)
          range_label = :week
          previous_from = (from - 1.week).beginning_of_week
          previous_to = (to - 1.week).end_of_week
        end
      end

      @from = from
      @to = to
      @previous_from = previous_from
      @previous_to = previous_to
      @range_label = range_label
    end

    # @overload current_time_zone
    # It sets the parking lot's timezone defined on tis settings.
    # Set timezone will be used to parse date ranges to get the equivalent datetime
    # of the parking lot's timezone, else, timezone will be default to UTC
    # sets instance variable @time_zone
    # @return [void]
    def current_time_zone
      return @time_zone if @time_zone.present?
      @time_zone ||= @parking_lots.uniq { |p| p.time_zone }.count == 1 ? @parking_lots.first.time_zone : 'UTC'
    end

    # @overload range_current_period
    # It returns string for current selected daterange
    # @example the range_label is :custom it returns
    #   JUN/01-JUN/25
    # @example the range_label is :this_week, it returns
    #   This week
    # @example else if count is zero? it returns
    #   NO DATA Last week
    # @return [String]
    def range_current_period
      if @range_label == :custom
        "#{@from.strftime("%^b/%d")}-#{@to.strftime("%^b/%d")}"
      else
        DATE_RANGE_LABELS[@range_label][:current]
      end
    end

    # @overload result_previous_period(count)
    # It returns string for current selected daterange
    # @param [Integer] count
    # @example the range_label is :custom it returns
    #   JUN/01-JUN/25
    # @example the range_label is :this_week, it returns
    #   Last week
    # @example else if count is zero? it returns
    #   NO DATA from Last week
    # @return [String]
    def result_previous_period(count)
      if @range_label == :custom
        "#{count.to_i.zero? ? 'NO DATA' : count} from #{@previous_from.strftime("%^b/%d")}-#{@previous_to.strftime("%^b/%d")}"
      else
        "#{count.to_i.zero? ? 'NO DATA' : count} from #{DATE_RANGE_LABELS[@range_label][:previous]}"
      end
    end
  end
end
