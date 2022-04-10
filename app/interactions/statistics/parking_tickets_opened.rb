module Statistics
  # @example instantiate and execute as
  #   ParkingTicketsIssued.new(params).result
  class ParkingTicketsOpened < ParkingTicketBase
    def set_parking_ticket_variables
      @title = '[Open] Citation Tickets'.freeze
      @data_label = 'Open Tickets'.freeze
      @status = :opened.freeze
    end
  end
end
