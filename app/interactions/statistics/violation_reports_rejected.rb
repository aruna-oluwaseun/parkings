module Statistics
  # Violation reports that have been reviewed but were deemed invalid.
  # @example instantiate and execute as
  #   ViolationReportsRejected.new(params).result
  class ViolationReportsRejected < ViolationReportsBase
    def set_parking_ticket_variables
      @title = '[Rejected] Violation Reports'.freeze
      @data_label = 'Rejected'.freeze
      @status = :rejected.freeze
    end
  end
end
