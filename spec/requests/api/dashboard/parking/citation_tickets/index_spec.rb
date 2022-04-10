require 'rails_helper'

RSpec.describe Api::Dashboard::Parking::CitationTicketsController, type: :request do
  let(:super_admin) { create(:admin, role: super_admin_role) }
  let(:town_manager) { create(:admin, role: town_manager_role) }
  let(:parking_admin) { create(:admin, role: parking_admin_role) }
  let(:agency_manager) { create(:admin, role: manager_role) }
  let(:officer) { create(:admin, role: officer_role) }
  let(:agency) { create(:agency, managers: [agency_manager]) }
  let(:params) { {} }
  let(:admin) { super_admin }

  before do
    agency_with_officers = create(:agency, officers: [officer])
    other_agency = create(:agency)

    create_list(:parking_ticket, 2, status: :approved, admin: parking_admin)
    create_list(:parking_ticket, 2, status: :approved, admin: town_manager, agency: other_agency)
    create_list(:parking_ticket, 2, status: :approved, admin: super_admin, agency: other_agency)
    create_list(:parking_ticket, 2, status: :approved, admin: agency_manager, agency: agency)
    create_list(:parking_ticket, 2, status: :approved, admin: officer, agency: agency_with_officers)

    Parking::Violation.all.each do |violation|
      create(:citation_ticket, violation: violation)
    end
  end

  describe 'GET #index' do
    context 'role restriction' do
      context 'success' do
        subject do
          get '/api/dashboard/parking/citation_tickets', headers: { Authorization: get_auth_token(admin) }, params: params
        end

        context 'when user role is super admin' do
          let(:admin) { super_admin }

          before { subject }

          it_behaves_like 'response_200', :show_in_doc

          it 'returns all existed citation tickets' do
            expect(json.size).to eq(Parking::Violation.count)
          end
        end

        context 'when user role is town manager' do
          let(:admin) { town_manager }

          before do
            parking_violation = create(:parking_ticket, status: :approved, admin: town_manager, agency: agency).violation
            create(:citation_ticket, violation: parking_violation)
            subject
          end

          it_behaves_like 'response_200', :show_in_doc

          it 'returns all citation tickets that town manager has access' do
            expect(json.size).to eq(3)
          end
        end

        context 'when user role is parking admin' do
          let(:admin) { parking_admin }

          before do
            parking_violation = create(:parking_ticket, status: :approved, admin: parking_admin, agency: agency).violation
            create(:citation_ticket, violation: parking_violation)
            subject
          end

          it_behaves_like 'response_200', :show_in_doc

          it 'returns all citation tickets that parking admin has access' do
            expect(json.size).to eq(3)
          end
        end

        context 'when user role is agency manager' do
          let(:admin) { agency_manager }

          before { subject }

          it_behaves_like 'response_200', :show_in_doc

          it 'returns all citation tickets that agency manager has access' do
            expect(json.size).to eq(2)
          end
        end

        context 'when user role is officer' do
          let(:admin) { officer }

          before { subject }

          it_behaves_like 'response_200', :show_in_doc

          it 'returns all citation tickets that officer has access' do
            expect(json.size).to eq(2)
          end
        end

        context 'pagination' do
          let(:admin) { super_admin }
          let(:params) { { per_page: 1 } }

          before { subject }

          it 'contains only one citation ticket' do
            expect(json.size).to eq(1)
          end
        end

        context 'with status filter parameter' do
          let(:params) { { status: :settled } }
          let(:expected_result) { I18n.t("activerecord.models.parking/citation_tickets.statuses.#{params[:status]}") }

          before do
            create(:citation_ticket, status: 'settled')
            subject
          end

          it 'returns citation tickets with settled status' do
            expect(json.size).to eq(1)
            expect(json.first['status']).to eq(expected_result)
          end

          it_behaves_like 'response_200', :show_in_doc
        end

        context 'with id filter parameter' do
          let(:params) { { id: @citation_ticket.id } }

          before do
            @citation_ticket = create(:citation_ticket)
            subject
          end

          it 'returns citation ticket with opropriate id' do
            expect(json.size).to eq(1)
            expect(json.first['id']).to eq(@citation_ticket.id)
          end

          it_behaves_like 'response_200', :show_in_doc
        end

        context 'with date filter' do
          let(:params) do
            {
              range: {
                from: '10/05/2020',
                to: '12/05/2020'
              }
            }
          end

          before do
            create(:citation_ticket, created_at: Time.zone.parse(params[:range][:from]))
            subject
          end

          it 'returns citation tickets corresponding date range filter' do
            expect(json.size).to eq(1)
          end

          it_behaves_like 'response_200', :show_in_doc
        end

        context 'with law officer filter' do
          let(:params) { { officer_id: @officer.id } }

          before do
            parking_ticket = create(:parking_ticket, agency: agency)
            @officer = create(:admin, role: officer_role)
            parking_ticket.update(admin_id: @officer.id)
            parking_violation = create(:parking_violation, ticket: parking_ticket)
            create(:citation_ticket, violation: parking_violation)
            subject
          end

          it 'returns citation tickets corresponding officer filter' do
            expect(json.size).to eq(1)
          end

          it_behaves_like 'response_200', :show_in_doc
        end

        context 'with parking lot filter' do
          let(:params) { { parking_lot_id: @parking_lot.id } }

          before do
            @parking_lot = create(:parking_lot)
            citation_ticket = create(:citation_ticket)
            citation_ticket.violation.rule.update(lot_id: @parking_lot.id)
            subject
          end

          it 'returns citation tickets corresponding parking lot filter' do
            expect(json.size).to eq(1)
          end

          it_behaves_like 'response_200', :show_in_doc
        end
      end

      context 'fail' do
        before do
          get '/api/dashboard/parking/citation_tickets'
        end

        it_behaves_like 'response_401'

        it 'returns unauthorized error' do
          expect(json[:error]).to eq('Unauthorized')
        end
      end
    end
  end
end
