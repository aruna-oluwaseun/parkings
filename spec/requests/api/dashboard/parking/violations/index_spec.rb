require 'rails_helper'

RSpec.describe Api::Dashboard::Parking::ViolationsController, type: :request do
  describe 'GET #index' do
    context 'get parking rule names' do
      let(:params) { {} }
      subject do
        get '/api/dashboard/parking_rules',
        headers: { Authorization: get_auth_token(admin) },
        params: params
      end

      context 'when user role is super admin' do
        let(:admin) { create(:admin, role: super_admin_role) }
        let(:agency) { create(:agency, admins: [admin]) }

        before do
          agencies = create_list(:agency, 2, admins: [admin])
          subject
        end

        context 'without filter params' do
          it 'returns all parking rule in the system' do
            expect(json.size).to eq(4)
          end

          it_behaves_like 'response_200', :show_in_doc
        end
      end
    end

    context 'success' do
      let(:params) { {} }
      subject do
        get '/api/dashboard/parking/violations',
        headers: { Authorization: get_auth_token(admin) },
        params: params
      end

      context 'when user role is super admin' do
        let(:admin) { create(:admin, role: super_admin_role) }
        let(:agency) { create(:agency, admins: [admin]) }

        before do
          agencies = create_list(:agency, 2, admins: [admin])
          create_list(:parking_ticket, 10, agency: agencies.sample, status: :opened)
        end

        context 'without filter params' do
          before { subject }

          it 'returns all parking violations in the system' do
            expect(json.size).to eq(10)
          end

          it_behaves_like 'response_200', :show_in_doc
        end

        context 'with ticket status filter parameter' do
          let(:params) { { ticket_status: :approved } }
          let(:expected_result) { I18n.t("activerecord.models.tickets.statuses.#{params[:ticket_status]}") }

          before do
            create(:parking_ticket, agency: agency, status: :approved)
            subject
          end

          it 'returns parking violations with approved status' do
            expect(json.size).to eq(1)
            expect(json.first['status']).to eq(expected_result)
          end

          it_behaves_like 'response_200', :show_in_doc
        end

        context 'with ticket id filter parameter' do
          let(:params) { { ticket_id: @parking_ticket.id } }

          before do
            @parking_ticket = create(:parking_ticket, agency: agency)
            subject
          end

          it 'returns parking violation with opropriate ticket id' do
            expect(json.size).to eq(1)
            expect(json.first['parking_ticket_id']).to eq(@parking_ticket.id)
          end

          it_behaves_like 'response_200', :show_in_doc
        end

        context 'with violation type filter parameter' do
          let(:params) { { violation_type: 'unpaid' } }
          let(:expected_result) { [I18n.t("activerecord.models.rules.description.#{params[:violation_type]}")] }

          before do
            parking_ticket = create(:parking_ticket, agency: agency)
            parking_ticket.violation.rule.update(name: ::Parking::Rule.names[:unpaid])
            subject
          end

          it 'returns parking violation with unpaid violation type' do
            expect(json.map { |violation| violation['violation_type'] }.uniq).to eq(expected_result)
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
            parking_ticket = create(:parking_ticket, agency: agency)
            parking_ticket.violation.update(created_at: Time.zone.parse(params[:range][:from]))
            subject
          end

          it 'returns parking violations corresponding date range filter' do
            expect(json.size).to eq(1)
          end

          it_behaves_like 'response_200', :show_in_doc
        end

        context 'with agency filter' do
          let(:params) { { agency_id: agency.id } }

          before do
            create(:parking_ticket, agency: agency)
            subject
          end

          it 'returns parking violations corresponding agency filter' do
            expect(json.map { |violation| violation['agency']['name'] }.uniq).to eq([agency.name])
          end

          it_behaves_like 'response_200', :show_in_doc
        end

        context 'with law officer filter' do
          let(:params) { { officer_id: @officer.id } }

          before do
            parking_ticket = create(:parking_ticket, agency: agency)
            @officer = create(:admin, role: officer_role)
            parking_ticket.update(admin_id: @officer.id)
            subject
          end

          it 'returns parking violations corresponding officer filter' do
            expect(json.first['officer']['id']).to eq(@officer.id)
          end

          it_behaves_like 'response_200', :show_in_doc
        end

        context 'with parking lot filter' do
          let(:params) { { parking_lot_id: @parking_lot.id } }

          before do
            parking_ticket = create(:parking_ticket, agency: agency)
            @parking_lot = create(:parking_lot)
            parking_ticket.violation.rule.update(lot_id: @parking_lot.id)
            subject
          end

          it 'returns parking violations corresponding parking lot filter' do
            expect(json.first['parking_lot']['id']).to eq(@parking_lot.id)
          end

          it_behaves_like 'response_200', :show_in_doc
        end
      end

      context 'when user role is town manager' do
        let(:town_manager) { create(:admin, role: town_manager_role) }
        let(:super_admin) { create(:admin, role: super_admin_role) }

        subject do
          get '/api/dashboard/parking/violations',
          headers: { Authorization: get_auth_token(town_manager) },
          params: params
        end

        before do
          agency = create(:agency, admins: [super_admin])
          create_list(:parking_ticket, 3, agency: agency)
          parking_lot = create(:parking_lot, admins: [town_manager])
          @parking_ticket = create(:parking_ticket, agency: agency)
          @parking_ticket.violation.rule.update(lot_id: parking_lot.id)
          subject
        end

        it 'returns parking violations that current user can manage' do
          expect(json.first['parking_ticket_id']).to eq(@parking_ticket.id)
        end
      end

      context 'when user role is officer' do
        let(:officer) { create(:admin, role: officer_role) }
        let(:town_manager) { create(:admin, role: town_manager_role) }

        subject do
          get '/api/dashboard/parking/violations',
          headers: { Authorization: get_auth_token(officer) },
          params: params
        end

        before do
          agency = create(:agency, admins: [town_manager, officer])
          @parking_tickets = create_list(:parking_ticket, 3, agency: agency)
          @parking_tickets.first.update(admin_id: officer.id)
          subject
        end

        it 'returns parking violations that officer can manage' do
          expect(json.first['parking_ticket_id']).to eq(@parking_tickets.first.id)
        end

        it_behaves_like 'response_200', :show_in_doc
      end

      context 'when user role is manager' do
        let(:manager) { create(:admin, role: manager_role) }
        let(:town_manager) { create(:admin, role: town_manager_role) }

        subject do
          get '/api/dashboard/parking/violations',
          headers: { Authorization: get_auth_token(manager) },
          params: params
        end

        before do
          agency = create(:agency, admins: [town_manager])
          create_list(:parking_ticket, 3, agency: agency)
          other_agency = create(:agency, admins: [manager])
          create_list(:parking_ticket, 2, agency: other_agency)
          subject
        end

        it 'returns parking violations opened in the parking lots that the user agency monitor' do
          expect(json.size).to eq(2)
        end

        it_behaves_like 'response_200', :show_in_doc
      end

      context 'when user role is parking admin' do
        let(:parking_admin) { create(:admin, role: parking_admin_role) }
        let(:super_admin) { create(:admin, role: super_admin_role) }

        subject do
          get '/api/dashboard/parking/violations',
          headers: { Authorization: get_auth_token(parking_admin) },
          params: params
        end

        before do
          agency = create(:agency, admins: [super_admin])
          create_list(:parking_ticket, 3, agency: agency)
          parking_lot = create(:parking_lot, admins: [parking_admin])
          @parking_ticket = create(:parking_ticket, agency: agency)
          @parking_ticket.violation.rule.update(lot_id: parking_lot.id)
          subject
        end

        it 'returns parking violations opened in the parking lots that current user can manage' do
          expect(json.first['parking_ticket_id']).to eq(@parking_ticket.id)
        end

        it_behaves_like 'response_200', :show_in_doc
      end
    end

    context 'parking violations sorting' do
      let(:params) {}
      subject do
        get '/api/dashboard/parking/violations',
        headers: { Authorization: get_auth_token(admin) },
        params: params
      end

      context 'sorting by violation type' do
        let(:admin) { create(:admin, role: super_admin_role) }
        let(:agency) { create(:agency, admins: [admin]) }

        before do
          agencies = create_list(:agency, 2, admins: [admin])
          parking_lot =  create(:parking_lot)
          parking_rule1 = create(:parking_rule, name: 'overlapping', lot_id: parking_lot.id)
          parking_rule2 = create(:parking_rule, name: 'unpaid', lot_id: parking_lot.id)
          parking_ticket1 = create(:parking_ticket, agency: agencies.sample, status: :opened)
          parking_ticket2 = create(:parking_ticket, agency: agencies.sample, status: :opened)
          violation1 = parking_ticket1.violation
          violation2 = parking_ticket2.violation
          violation1.update!(rule: parking_rule1)
          violation2.update!(rule: parking_rule2)
        end

        context 'sorting desc' do
          let(:params) { { "order[keyword]": "parking_rules.name", "order[direction]": "desc" } }

          before { subject }

          it 'returns all parking violations sorting by type' do
            expect(json.first["violation_type"]).to eq('Unpaid')
          end
        end

        context 'sorting asc' do
          let(:params) { { "order[keyword]": "parking_rules.name", "order[direction]": "asc" } }

          before { subject }

          it 'returns all parking violations sorting by type' do
            expect(json.first["violation_type"]).to eq('Overlapping')
          end
        end
        it_behaves_like 'response_200', :show_in_doc
      end

      context 'sorting by parking lots name' do
        let(:parking_admin) { create(:admin, role: parking_admin_role) }
        let(:admin) { create(:admin, role: super_admin_role) }

        before do
          agency = create(:agency, admins: [admin])
          parking_lot1 = create(:parking_lot, name: "Parking Lot #1", admins: [parking_admin])
          parking_lot2= create(:parking_lot, name: "Parking Lot #2", admins: [parking_admin])
          parking_ticket1 = create(:parking_ticket, agency: agency)
          parking_ticket1.violation.rule.update(lot_id: parking_lot1.id)
          parking_ticket2 = create(:parking_ticket, agency: agency)
          parking_ticket2.violation.rule.update(lot_id: parking_lot2.id)
          subject
        end

        context 'sorting desc' do
          let(:params) { { "order[keyword]": "parking_lots.name", "order[direction]": "desc" } }

          before { subject }

          it 'returns all parking violations sorting by parking lot names' do
            expect(json.first["parking_lot"]["name"]).to eq("Parking Lot #2")
          end
        end

        context 'sorting asc' do
          let(:params) { { "order[keyword]": "parking_lots.name", "order[direction]": "asc" } }

          before { subject }

          it 'returns all parking violations sorting by parking lot names' do
            expect(json.first["parking_lot"]["name"]).to eq("Parking Lot #1")
          end
        end
        it_behaves_like 'response_200', :show_in_doc
      end

      context 'sorting by officer name' do
        let(:parking_admin1) { create(:admin, role: parking_admin_role, name: "Admin 1") }
        let(:parking_admin2) { create(:admin, role: parking_admin_role, name: "Admin 2") }
        let(:admin) { create(:admin, role: super_admin_role) }

        before do
          agency = create(:agency, admins: [admin])
          parking_ticket1 = create(:parking_ticket, agency: agency, admin: parking_admin1)
          parking_ticket2 = create(:parking_ticket, agency: agency, admin: parking_admin2)
          subject
        end

        context 'sorting desc' do
          let(:params) { { "order[keyword]": "officers.name", "order[direction]": "desc" } }

          before { subject }

          it 'returns all parking violations sorting by officer names' do
            expect(json.first["officer"]["name"]).to eq("Admin 2")
          end
        end

        context 'sorting asc' do
          let(:params) { { "order[keyword]": "officers.name", "order[direction]": "asc" } }

          before { subject }

          it 'returns all parking violations sorting by officer names' do
            expect(json.first["officer"]["name"]).to eq("Admin 1")
          end
        end
        it_behaves_like 'response_200', :show_in_doc
      end

      context 'sorting by agencies name' do
        let(:parking_admin) { create(:admin, role: parking_admin_role) }
        let(:admin) { create(:admin, role: super_admin_role) }

        before do
          agency1 = create(:agency, name: "Agency 1", admins: [admin])
          agency2 = create(:agency, name: "Agency 2", admins: [admin])
          parking_ticket1 = create(:parking_ticket, agency: agency1, admin: parking_admin)
          parking_ticket2 = create(:parking_ticket, agency: agency2, admin: parking_admin)
          subject
        end

        context 'sorting desc' do
          let(:params) { { "order[keyword]": "agencies.name", "order[direction]": "desc" } }

          before { subject }

          it 'returns all parking violations sorting by officer names' do
            expect(json.first["agency"]["name"]).to eq("Agency 2")
          end
        end

        context 'sorting asc' do
          let(:params) { { "order[keyword]": "agencies.name", "order[direction]": "asc" } }

          before { subject }

          it 'returns all parking violations sorting by officer names' do
            expect(json.first["agency"]["name"]).to eq("Agency 1")
          end
        end
        it_behaves_like 'response_200', :show_in_doc
      end

      context 'sorting by status' do
        let(:parking_admin) { create(:admin, role: parking_admin_role) }
        let(:admin) { create(:admin, role: super_admin_role) }

        before do
          agency = create(:agency, admins: [admin])
          parking_ticket1 = create(:parking_ticket, agency: agency, admin: parking_admin, status: :opened)
          parking_ticket2 = create(:parking_ticket, agency: agency, admin: parking_admin, status: :rejected)
          subject
        end

        context 'sorting desc' do
          let(:params) { { "order[keyword]": "parking_tickets.status", "order[direction]": "desc" } }

          before { subject }

          it 'returns all parking violations sorting by officer names' do
            expect(json.first["status"]).to eq("Rejected")
          end
        end

        context 'sorting asc' do
          let(:params) { { "order[keyword]": "parking_tickets.status", "order[direction]": "asc" } }

          before { subject }

          it 'returns all parking violations sorting by officer names' do
            expect(json.first["status"]).to eq("Open")
          end
        end
        it_behaves_like 'response_200', :show_in_doc
      end
    end

    context 'fail' do
      context 'unauthorized user' do
        before do
          get '/api/dashboard/parking/violations'
        end

        it 'returns unauthorized error message' do
          expect(json[:error].present?).to be true
        end

        it_behaves_like 'response_401'
      end
    end
  end
end
