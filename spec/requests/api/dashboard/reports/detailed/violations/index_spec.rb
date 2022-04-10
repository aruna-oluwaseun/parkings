require 'rails_helper'

RSpec.describe Api::Dashboard::Reports::Detailed::ViolationsController, type: :request do
  describe 'GET #index' do
    let(:admin) { create(:admin, role: super_admin_role) }
    let(:today) { Time.now.utc.beginning_of_day }
    let(:params) { {} }

    subject do
      get '/api/dashboard/reports/detailed/violations', headers: { Authorization: get_auth_token(admin) }, params: params
    end

    before do
      subject
    end

    context 'success' do
      context 'when violation status param does not set' do
        it 'returns json response for open violations report' do
          expect(json.present?).to be true
          expect(json[:title]).to eq('Violation Reports')
        end

        it_behaves_like 'response_200', :show_in_doc
      end

      context 'when violation status param setted to rejected' do
        let(:params) { { violation_status: 'rejected' } }

        it 'returns json response for rejected violations report' do
          expect(json.present?).to be true
          expect(json[:title]).to eq('Rejected Violation Reports')
        end

        it_behaves_like 'response_200', :show_in_doc
      end
    end

    context 'fail: unauthorized' do
      subject do
        get '/api/dashboard/reports/detailed/violations', params: params
      end

      it 'returns unauthorized error' do
        expect(json[:error]).to eq('Unauthorized')
      end

      it_behaves_like 'response_401'
    end
  end
end
