require 'rails_helper'

describe Api::Dashboard::Parking::ViolationHistoryLogsController, type: :request do
  let(:admin) { create(:admin, role: super_admin_role) }

  describe '#index' do
    let(:violation) do
      create(:parking_violation, :with_parking_session, :with_opened_violation_ticket, :with_image)
    end
    let(:ticket) { violation.ticket }
    let(:parking_lot) { violation.parking_lot }
    let(:vehicle) { violation.vehicle }

    subject do
      get "/api/dashboard/parking/violations/#{violation.id}/violation_history_logs",
            headers: { Authorization: get_auth_token(admin) }, params: params
    end

    context 'without filtering params' do
      let(:params) { {} }

      before do
        ticket.update(status: Parking::Ticket::STATUSES[:closed], admin: create(:admin))
        parking_lot.update(name: 'Parking Ways')
        vehicle.update(plate_number: 'CCM-9419')
        subject
        @log_attributes = json.map { |log| log['attribute'] }.uniq
      end

      it_behaves_like 'response_200', :show_in_doc

      it 'has logs' do
        expect(@log_attributes).to match_array ['Change of Assignee', 'Change of Status']
      end
    end

    context 'with filtering params' do
      context 'with date filter' do
        let(:params) do
          {
            range: {
              from: Time.zone.now.strftime('%Y-%m-%d'),
              to: (Time.zone.now + 3.days).strftime('%Y-%m-%d')
            }
          }
        end

        before { subject }

        it 'returns logs created today' do
          expect(json.size).to eq(0)
        end
      end

      context 'with activity log filter' do
        let(:params) { { activity_log: 'Change of Status' } }

        before do
          ticket.update(status: Parking::Ticket::STATUSES[:closed], admin: create(:admin))
          subject
        end

        it 'returns logs related with status changing' do
          expect(json.size).to eq(1)
          expect(json.first['attribute']).to eq('Change of Status')
        end
      end
    end
  end
end
