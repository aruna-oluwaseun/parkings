require 'rails_helper'

RSpec.describe Api::Dashboard::Reports::Detailed::RevenuesController, type: :request do
  describe 'GET #index' do
    let(:admin) { create(:admin, role: super_admin_role) }
    let(:today) { Time.now.utc.beginning_of_day }
    let(:params) { {} }

    subject do
      get '/api/dashboard/reports/detailed/revenues', headers: { Authorization: get_auth_token(admin) }, params: params
    end

    before do
      subject
    end

    context 'success' do
      it 'returns json response' do
        expect(json.present?).to be true
        expect(json[:title]).to eq('Revenues Earned Reports')
      end

      it_behaves_like 'response_200', :show_in_doc
    end

    context 'fail: unauthorized' do
      subject do
        get '/api/dashboard/reports/detailed/revenues', params: params
      end

      it 'returns unauthorized error' do
        expect(json[:error]).to eq('Unauthorized')
      end

      it_behaves_like 'response_401'
    end
  end
end
