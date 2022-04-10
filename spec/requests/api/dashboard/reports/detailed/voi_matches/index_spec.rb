require 'rails_helper'

RSpec.describe Api::Dashboard::Reports::Detailed::VoiMatchesController, type: :request do
  describe 'GET #index' do
    let(:admin) { create(:admin, role: super_admin_role) }
    let(:today) { Time.now.utc.beginning_of_day }
    let(:params) { {} }

    subject do
      get '/api/dashboard/reports/detailed/voi_matches', headers: { Authorization: get_auth_token(admin) }, params: params
    end

    before do
      subject
    end

    context 'success' do
      let(:expected_json_structure) do
        {
          'title' => 'VOI Matches Report',
          'pie_chart_data' => {
            'Voi Matches' => {}
          },
          'pie_chart_total' => {
            'Voi Matches' => 0
          },
          'parking_lots' => []
        }
      end

      it 'returns json response' do
        expect(json.present?).to be true
        expect(json[:title]).to eq('VOI Matches Report')
      end

      it 'responses with a certain JSON structure' do
        expect(json).to eq(expected_json_structure)
      end

      it_behaves_like 'response_200', :show_in_doc
    end

    context 'fail: unauthorized' do
      subject do
        get '/api/dashboard/reports/detailed/voi_matches', params: params
      end

      it 'returns unauthorized error' do
        expect(json[:error]).to eq('Unauthorized')
      end

      it_behaves_like 'response_401'
    end
  end
end
