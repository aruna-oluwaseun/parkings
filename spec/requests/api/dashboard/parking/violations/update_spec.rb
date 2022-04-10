require 'rails_helper'

RSpec.describe Api::Dashboard::Parking::ViolationsController, type: :request do
  let(:admin) { create(:admin, role: super_admin_role) }
  let(:manager) { create(:admin, role: manager_role) }
  let(:parking_violation) { create(:parking_violation, :with_opened_violation_ticket) }
  let(:image) { fixture_base64_file_upload('spec/files/test.jpg') }
  let(:valid_params) do
    {
     parking_violation: {
       status: 'opened',
       admin_id: manager.id,
       images: [image]
     }
    }
  end

  describe 'PUT #update' do
    context 'success' do
      subject do
        put "/api/dashboard/parking/violations/#{parking_violation.id}",
          headers: { Authorization: get_auth_token(admin) }, params: valid_params
      end

      context 'when updates status to approved' do
        let(:valid_params) do
          {
           parking_violation: {
             status: 'approved',
             admin_id: manager.id,
             images: [image]
           }
          }
        end

        before do
          subject
          parking_violation.reload
          parking_violation.ticket.reload
        end

        it_behaves_like 'response_200', :show_in_doc

        it 'updates the parking violation and do not create citation ticket' do
          expect(parking_violation.ticket.status).to eq(valid_params[:parking_violation][:status])
          expect(parking_violation.ticket.admin_id).to eq(valid_params[:parking_violation][:admin_id])
          expect(parking_violation.citation_ticket.present?).to be true
          expect(parking_violation.images.size).to eq(1)
        end
      end

      context 'when updates and destroys images' do
        let(:valid_params) do
          {
           parking_violation: {
             status: 'approved',
             admin_id: manager.id,
             images: [image],
             images_ids: [@image.id]
           }
          }
        end

        before do
          @image = parking_violation.images.create(file: { data: image })
          subject
          parking_violation.reload
        end

        it 'deletes appropriate image and uploads a new one' do
          expect(parking_violation.images.ids.include?(@image.id)).to be false
        end
      end
    end

    context 'fail' do
      context 'unauthorized' do
        subject do
          put "/api/dashboard/parking/violations/#{parking_violation.id}", params: valid_params
        end

        before { subject }

        it 'returns unauthorized error' do
          subject
          expect(json[:error]).to eq('Unauthorized')
        end

        it_behaves_like 'response_401'
      end

      context 'not allowed status transaction' do
        let(:admin) { create(:admin, role: officer_role) }
        let(:valid_params) do
          {
           parking_violation: {
             status: 'rejected',
             admin_id: admin.id
           }
          }
        end

        subject do
          put "/api/dashboard/parking/violations/#{parking_violation.id}", headers: { Authorization: get_auth_token(admin) }, params: valid_params
        end

        before do
          parking_violation.ticket.agency.officers << admin
          subject
          parking_violation.reload
        end

        it 'don\'t update status and return error message' do
          expect(json['errors'].present?).to be true
          expect(parking_violation.ticket.status).to eq('opened')
        end
      end

      context 'when image size is more then 1.5MB' do
        let(:image) { fixture_base64_file_upload('spec/files/test_image.jpg') }
        let(:valid_params) do
          {
           parking_violation: {
              status: 'opened',
              admin_id: manager.id,
              images: [image]
           }
          }
        end

        subject do
          put "/api/dashboard/parking/violations/#{parking_violation.id}", headers: { Authorization: get_auth_token(admin) }, params: valid_params
        end

        before do
          subject
        end

        it 'does not upload image and returns error message' do
          expect(json[:errors][:image].present?).to be true
          expect(parking_violation.images.size).to eq(0)
        end
      end

      context 'when parking violation does not exist' do
        subject do
          put "/api/dashboard/parking/violations/invalid_id", headers: { Authorization: get_auth_token(admin) }, params: valid_params
        end

        it_behaves_like 'response_404'
      end
    end
  end
end
