class UpdateAllTicketStatuses < ActiveRecord::Migration[5.2]
  def change
    UpdateParkingTicketStatuses.new(:closed, :approved).call
  end
end
