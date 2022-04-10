require 'rails_helper'

RSpec.describe Api::Dashboard::CommentsController, type: :request do
  describe 'PUT #update' do
    let(:admin) { create(:admin, role: super_admin_role) }
    let(:parking_violation) { create(:parking_violation) }
    let(:comment) { create(:comment, :with_violation, subject: parking_violation, admin: admin) }

    context 'success' do
      let(:params) do
        {
          comment: {
            content: 'new content'
          }
        }
      end

      subject do
        put "/api/dashboard/comments/#{comment.id}", headers: { Authorization: get_auth_token(admin) }, params: params
      end

      before do
        subject
        comment.reload
      end

      it_behaves_like 'response_200', :show_in_doc

      it 'updates comment' do
        expect(comment.content).to eq(params[:comment][:content])
      end
    end

    context 'fail' do
      before { subject }

      context 'unauthorized' do
        subject do
          put "/api/dashboard/comments/#{comment.id}"
        end

        it 'returns unauthorized error' do
          expect(json[:error]).to eq('Unauthorized')
        end

        it_behaves_like 'response_401', :show_in_doc
      end

      context 'when the comment doesn\'t exists' do
        subject do
          put "/api/dashboard/comments/invalid_id", headers: { Authorization: get_auth_token(admin) }
        end

        it_behaves_like 'response_404', :show_in_doc
      end
    end
  end
end
