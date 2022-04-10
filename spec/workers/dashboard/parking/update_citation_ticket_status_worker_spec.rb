require 'rails_helper'

RSpec.describe Dashboard::Parking::UpdateCitationTicketStatusWorker, type: :worker do
  let(:parking_violation) { create(:parking_violation, :with_opened_violation_ticket) }

  describe '#perform' do
    context 'with unsettled status' do
      let(:citation_ticket) { create(:citation_ticket, violation: parking_violation, status: :unsettled) }

      before do
        described_class.perform_async(citation_ticket.id)
        citation_ticket.reload
      end

      it 'updates citation ticket status to sent_to_court and violation status to closed' do
        expect(citation_ticket.status).to eq('sent_to_court')
        expect(citation_ticket.violation.ticket.status).to eq('closed')
      end
    end

    context 'when status settled' do
      let(:citation_ticket) { create(:citation_ticket, violation: parking_violation, status: :settled) }

      before do
        @current_status = citation_ticket.status
        described_class.perform_async(citation_ticket.id)
        citation_ticket.reload
      end

      it 'does not update citation ticket status' do
        expect(citation_ticket.status).to eq(@current_status)
      end
    end
  end
end
