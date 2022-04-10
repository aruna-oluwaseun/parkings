module Statistics
  # @example instantiate and execute as
  # CitationTicketsBase.new(params).result
  class CitationTicketsBase < Base
    set_callback :execute, :before, -> do
      set_citation_ticket_variables
    end

    def execute
      parking_lot_ids = @parking_lots.map(&:id).join("-")
      cache_date = "#{@from.strftime('%m-%d-%y')}_#{@to.strftime('%m-%d-%y')}"
      Rails.cache.fetch("statistics/citation_ticket/#{parking_lot_ids}/#{cache_date}/#{@status}", expires_in: CACHE_EXPIRE_TIME) do
        scope = ::Parking::CitationTicket.send(@status.to_sym).with_role_condition(current_user).by_parking_lot_ids(@parking_lots.map(&:id))
        current_scope_count = scope.where(created_at: @from..@to).count
        {
          title: @title,
          range_current_period: range_current_period,
          result: current_scope_count.zero? ? I18n.t('api.errors.no_data') : "#{number_with_delimiter(current_scope_count)} #{@data_label}",
        }
      end
    end
  end
end