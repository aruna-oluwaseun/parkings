require 'rails_helper'

RSpec.describe Api::Dashboard::AgenciesController, type: :request do

  describe 'DELETE #destroy' do
    let(:admin) { create(:admin, role: super_admin_role) }

    subject do
      delete "/api/dashboard/agencies/#{agency.id}", headers: { Authorization: get_auth_token(admin) }
    end

    context 'success' do
      context 'when agency has not officers or opened parking tickets' do
        let!(:agency) { create(:agency) }

        it 'deleteds agency' do
          expect { subject }.to change(Agency, :count).by(-1)
        end

        it_behaves_like 'response_200', :show_in_doc
      end
    end

    context 'fail' do
      let(:manager) { create(:admin, role: manager_role) }
      let(:officers) { create_list(:admin, 2, role: officer_role) }

      shared_examples 'do not delete agency' do
        it 'returns error message' do
          expect(json[:errors].present?).to be true
        end
      end

      context 'when agency has opened parking tickets' do
        let(:agency) { create(:agency, admins: [manager].flatten) }

        before do
          create(:parking_ticket, status: 'opened', agency: agency)
          subject
        end

        it_behaves_like 'do not delete agency', :show_in_doc

        it_behaves_like 'response_422', :show_in_doc
      end

      context 'when agency has officers' do
        let(:agency) { create(:agency, admins: [manager, officers].flatten) }

        before { subject }

        it_behaves_like 'do not delete agency', :show_in_doc

        it_behaves_like 'response_422', :show_in_doc
      end
    end
  end
end
