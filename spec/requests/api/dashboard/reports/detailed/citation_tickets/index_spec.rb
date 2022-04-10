require 'rails_helper'

RSpec.describe Api::Dashboard::Reports::Detailed::CitationTicketsController, type: :request do
  describe 'GET #index' do
    let(:admin) { create(:admin, role: super_admin_role) }
    let(:today) { Time.now.utc.beginning_of_day }
    let(:params) { {} }

    subject do
      get '/api/dashboard/reports/detailed/citation_tickets', headers: { Authorization: get_auth_token(admin) }, params: params
    end

    before do
      subject
    end

    context 'success' do
      it 'returns json response' do
        expect(json.present?).to be true
        expect(json[:title]).to eq('Citation Ticket Reports')
      end

      it_behaves_like 'response_200', :show_in_doc

      context 'when citation ticket status param setted' do
        let(:params) { { citation_ticket_status: 'unsettled' } }

        it 'returns json response for opened violations report' do
          expect(json.present?).to be true
          expect(json[:title]).to eq('Open Citation Tickets Reports')
        end

        it_behaves_like 'response_200', :show_in_doc
      end
    end

    context 'fail: unauthorized' do
      subject do
        get '/api/dashboard/reports/detailed/citation_tickets', params: params
      end

      it 'returns unauthorized error' do
        expect(json[:error]).to eq('Unauthorized')
      end

      it_behaves_like 'response_401'
    end
  end
end
