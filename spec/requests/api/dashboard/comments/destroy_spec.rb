require 'rails_helper'

RSpec.describe Api::Dashboard::CommentsController, type: :request do
  describe 'DELETE #destroy' do
    let(:admin) { create(:admin, role: super_admin_role) }
    let(:parking_violation) { create(:parking_violation) }

    before do
      create_list(:comment, 10, :with_violation, subject: parking_violation, admin: admin)
    end

    context 'success' do
      let(:comment) { parking_violation.comments.last }

      subject do
        delete "/api/dashboard/comments/#{comment.id}", headers: { Authorization: get_auth_token(admin) }
      end

      it_behaves_like 'response_200', :show_in_doc

      it 'returns 9 comments' do
        subject
        expect(parking_violation.comments.count).to eq(9)
      end
    end

    context 'fail' do
      let(:comment) { parking_violation.comments.last }

      context 'unauthorized' do
        subject do
          delete "/api/dashboard/comments/#{comment.id}"
        end

        it 'returns unauthorized error' do
          subject
          expect(json[:error]).to eq('Unauthorized')
        end

        it_behaves_like 'response_401', :show_in_doc
      end

      context 'when the comment doesn\'t exists' do
        subject do
          delete "/api/dashboard/comments/invalid_id", headers: { Authorization: get_auth_token(admin) }
        end

        it_behaves_like 'response_404', :show_in_doc
      end
    end
  end
end
