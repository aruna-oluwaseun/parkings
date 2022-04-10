
module Statistics
  # Violation Reports that have not been reviewed yet from the covered parking lots.
  # @example instantiate and execute as
  #   ViolationReportsOpened.new(params).result
  class CitationTicketsOpened < CitationTicketsBase
    def set_citation_ticket_variables
      @title = '[Open] Citation Tickets'.freeze
      @data_label = 'Open'.freeze
      @status = :unsettled.freeze
    end
  end
end
