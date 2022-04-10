require 'rails_helper'

RSpec.describe Api::Dashboard::CommentsController, type: :request do
  describe 'GET #index' do
    let(:admin) { create(:admin, role: officer_role) }
    let(:parking_violation) { create(:parking_violation) }
    let(:parking_ticket) { create(:parking_ticket) }

    context 'success' do
      subject do
        get '/api/dashboard/comments',
        headers: { Authorization: get_auth_token(admin) }, params: params
      end

      context 'when subject is a parking violation' do
        context 'without filtering params' do
          let(:params) do
            {
              subject_type: 'Parking::Violation',
              subject_id: parking_violation.id
            }
          end

          before do
            create_list(:comment, 5, :with_violation, subject: parking_violation)
            subject
          end

          it_behaves_like 'response_200', :show_in_doc

          it 'returns 5 comments' do
            expect(json.size).to eq(5)
          end
        end

        context 'with filtering params' do
          context 'with date filter' do
            let(:params) do
              {
                subject_type: 'Parking::Violation',
                subject_id: parking_violation.id,
                range: {
                  from: '10/05/2020',
                  to: '12/05/2020'
                }
              }
            end

            before do
              create_list(:comment, 5, :with_violation, subject: parking_violation)
              Comment.last.update(created_at: Time.zone.parse(params[:range][:from]))
              subject
            end

            it 'returns comments corresponding date range filter' do
              expect(json.size).to eq(1)
            end
          end

          context 'with officer filter' do
            let(:params) do
              {
                subject_type: 'Parking::Violation',
                subject_id: parking_violation.id,
                officer_id: admin.id
              }
            end

            before do
              create_list(:comment, 5, :with_violation, subject: parking_violation, admin: admin)
              subject
            end

            it 'returns comments corresponding officer filter' do
              expect(json.size).to eq(5)
            end
          end
        end
      end

      context 'when params are not included' do
        subject do
          get '/api/dashboard/comments',
          headers: { Authorization: get_auth_token(admin) }
        end

        before { subject }

        it 'have 0 items' do
          expect(json.size).to eq(0)
        end

        it_behaves_like 'response_200'
      end
    end

    context 'fail: unauthorized' do
      subject do
        get '/api/dashboard/comments',
        params: {
           subject_type: 'Parking::Violation',
           subject_id: parking_violation.id
        }
      end

      before { subject }

      it 'returns unauthorized error' do
        expect(json[:error]).to eq('Unauthorized')
      end

      it_behaves_like 'response_401'
    end
  end
end
