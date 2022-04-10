require 'rails_helper'

describe Api::Dashboard::Parking::CitationTicketHistoryLogsController, type: :request do
  let(:admin) { create(:admin, role: super_admin_role) }

  describe '#index' do
    let(:citation_ticket) do
      create(:citation_ticket, status: :unsettled)
    end
    let(:params) { {} }

    subject do
      get "/api/dashboard/parking/citation_tickets/#{citation_ticket.id}/citation_ticket_history_logs",
        headers: { Authorization: get_auth_token(admin) }, params: params
    end

    before do
      citation_ticket.update(status: Parking::CitationTicket::STATUSES[:settled])
      subject
    end

    it_behaves_like 'response_200', :show_in_doc

    it 'has status changes logs' do
      expect(json.any?).to be true
    end
  end
end
