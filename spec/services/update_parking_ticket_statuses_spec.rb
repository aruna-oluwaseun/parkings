require 'rails_helper'

describe UpdateParkingTicketStatuses do
  describe '#call' do
    subject { ::UpdateParkingTicketStatuses.new(:closed, :approved).call }

    context 'when parking ticket status is closed' do
      before do
        parking_tickets = create_list(:parking_ticket, 3, status: :closed)
        create_list(:parking_ticket, 2, status: :opened)
        subject
      end

      it 'updates all parking tickets with closed status to approved' do
        expect(Parking::Ticket.approved.size).to eq(3)
      end
    end
  end
end
