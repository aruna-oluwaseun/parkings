module Statistics
  # Citation tickets that are already resolved/settled.
  # @example instantiate and execute as
  #   ParkingTicketsSettled.new(params).result
  class ParkingTicketsSettled < ParkingTicketBase
    def set_parking_ticket_variables
      @title = '[Settled] Citation Tickets'.freeze
      @data_label = 'Settled Tickets'.freeze
      @status = :closed.freeze
    end
  end
end
