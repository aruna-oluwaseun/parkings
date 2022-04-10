require 'rails_helper'

RSpec.describe Api::Dashboard::CommentsController, type: :request do
  describe 'POST #create' do
    let(:admin) { create(:admin, role: super_admin_role) }
    let(:parking_violation) { create(:parking_violation) }
    let(:parking_ticket) { create(:parking_ticket) }

    context 'success' do
      context 'when is a parking violation' do
        subject do
          post '/api/dashboard/comments', headers: { Authorization: get_auth_token(admin) },
          params:
          {
            comment: {
              content: Faker::Lorem.sentence,
              subject_type: 'Parking::Violation',
              subject_id: parking_violation.id
            }
          }
        end

        it_behaves_like 'response_201', :show_in_doc

        it 'creates a new comment in the parking violation report' do
          subject
          expect(parking_violation.comments.size).to eq(1)
        end
      end
    end

    context 'fail' do
      context 'unauthorized' do
        subject do
          get '/api/dashboard/comments',
          params: {
            subject_type: 'Parking::Violation',
            subject_id: parking_violation.id
          }
        end

        it 'returns unauthorized error' do
          subject
          expect(json[:error]).to eq('Unauthorized')
        end

        it_behaves_like 'response_401', :show_in_doc
      end
    end

    context 'when the required params are not present' do
      subject do
        post '/api/dashboard/comments', headers: { Authorization: get_auth_token(admin) }
      end

      it_behaves_like 'response_422', :show_in_doc

      it 'returns comment errors' do
        subject
        expect(json[:errors].present?).to eq(true)
      end
    end
  end
end
