require 'rails_helper'

RSpec.describe Api::Dashboard::Parking::CitationTicketsController, type: :request do
  describe 'POST #create' do
    let(:admin) { create(:admin, role: super_admin_role) }
    let(:manager) { create(:admin, role: manager_role) }
    let(:agency) { create(:agency, managers: [admin]) }
    let(:parking_lot) { create(:parking_lot) }
    let(:params) do
      {
        citation_ticket: {
          status: 'settled',
          parking_violation: {
            plate_number: 'AE3423',
            agency_id: agency.id,
            officer_id: admin.id,
            images: [fixture_base64_file_upload('spec/files/test.jpg')],
            parking_lot: {
              id: parking_lot.id
            },
            parking_rule: {
              name: 'overlapping'
            },
            parking_ticket: {
              officer_id: admin.id
            }
          }
        }
      }
    end

    context 'success' do
      subject do
        post '/api/dashboard/parking/citation_tickets',
              headers: { Authorization: get_auth_token(manager) },
              params: params
      end

      before do
        create(:parking_rule, name: 'overlapping', lot_id: parking_lot.id)
      end

      context 'with valid params' do
        let(:expected_status) { I18n.t("activerecord.models.parking/citation_tickets.statuses.#{params[:citation_ticket][:status]}") }

        it_behaves_like 'response_201'

        it 'creates new citation ticket' do
          expect { subject }.to change(Parking::CitationTicket, :count).by(1)
        end

        it 'creates new citation ticket with with given parameters' do
          subject
          expect(json[:plate_number]).to eq('AE3423')
          expect(json[:status]).to eq(expected_status)
        end
      end
    end

    context 'failure' do
      context 'when user unauthorized' do

        before { post '/api/dashboard/parking/citation_tickets' }

        it_behaves_like 'response_401'

        it 'returns unauthorized error' do
          expect(json[:error]).to eq('Unauthorized')
        end
      end

      context 'with invalid params' do
        let(:params) { {} }

        before do
          post '/api/dashboard/parking/citation_tickets',
                headers: { Authorization: get_auth_token(manager) },
                params: params
        end

        it 'returns error messages' do
          errors = json[:errors]
          expect(errors[:plate_number].first).to eq(I18n.t('activerecord.errors.messages.missing', attribute: 'Plate number'))
          expect(errors[:agency_id].first).to eq(I18n.t('activerecord.errors.messages.missing', attribute: 'Agency'))
          expect(errors[:officer_id].first).to eq(I18n.t('activerecord.errors.messages.missing', attribute: 'Officer'))
          expect(errors[:parking_lot].first).to eq(I18n.t('activerecord.errors.messages.missing', attribute: 'Parking lot'))
          expect(errors[:parking_rule].first).to eq(I18n.t('activerecord.errors.messages.missing', attribute: 'Parking rule'))
        end
      end
    end
  end
end
