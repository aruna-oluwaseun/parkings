class UpdateParkingTicketStatuses
  attr_reader :old_status, :new_status

  def initialize(old_status, new_status)
    @old_status = old_status
    @new_status = new_status
  end

  def call
    Parking::Ticket.where(status: old_status).update_all(status: new_status)
  end
end
