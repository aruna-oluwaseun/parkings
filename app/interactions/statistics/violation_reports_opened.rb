module Statistics
  # Violation Reports that have not been reviewed yet from the covered parking lots.
  # @example instantiate and execute as
  #   ViolationReportsOpened.new(params).result
  class ViolationReportsOpened < ViolationReportsBase
    def set_parking_ticket_variables
      @title = '[Open] Violation Reports'.freeze
      @data_label = 'Open'.freeze
      @status = :opened.freeze
    end
  end
end
