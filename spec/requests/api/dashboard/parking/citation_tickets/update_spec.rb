require 'rails_helper'

RSpec.describe Api::Dashboard::Parking::CitationTicketsController, type: :request do
  let(:admin) { create(:admin, role: super_admin_role) }
  let(:manager) { create(:admin, role: manager_role) }
  let(:parking_violation) { create(:parking_violation, :with_opened_violation_ticket) }
  let(:citation_ticket) { create(:citation_ticket, violation: parking_violation) }
  let(:image) { fixture_base64_file_upload('spec/files/test.jpg') }
  let(:valid_params) do
    {
     citation_ticket: {
       status: 'settled',
       images: [image]
     }
    }
  end

  describe 'PUT #update' do
    context 'success' do
      subject do
        put "/api/dashboard/parking/citation_tickets/#{citation_ticket.id}",
          headers: { Authorization: get_auth_token(admin) }, params: valid_params
      end

      shared_examples 'updates citation ticket status and updates parking ticket status to closed' do
        it 'updates parking ticket status to closed' do
          expect(citation_ticket.status).to eq(valid_params[:citation_ticket][:status])
          expect(citation_ticket.violation.ticket.status).to eq('closed')
        end
      end

      context 'when user updates citation ticket status to settled' do
        before do
          subject
          @parking_ticket_status = citation_ticket.violation.ticket.status
          citation_ticket.reload
        end

        it_behaves_like 'response_200', :show_in_doc

        it 'uploads violation image' do
          expect(citation_ticket.violation.images.size).to eq(1)
        end

        it_behaves_like 'updates citation ticket status and updates parking ticket status to closed'
      end

      context 'when user updates citation ticket status to canceled' do
        let(:valid_params) do
          {
           citation_ticket: {
             status: 'canceled'
           }
          }
        end

        before do
          subject
          citation_ticket.reload
        end

        it_behaves_like 'updates citation ticket status and updates parking ticket status to closed'
      end

      context 'when user updates citation ticket status to sent_to_court' do
        let(:valid_params) do
          {
           citation_ticket: {
             status: 'sent_to_court'
           }
          }
        end

        before do
          subject
          citation_ticket.reload
        end

        it_behaves_like 'updates citation ticket status and updates parking ticket status to closed'
      end

      context 'when updates and destroys images' do
        let(:valid_params) do
          {
            citation_ticket: {
              status: 'settled',
              images: [image],
              images_ids: [@image.id]
           }
          }
        end

        before do
          @image = citation_ticket.violation.images.create(file: { data: image })
          subject
        end

        it 'deletes appropriate image and uploads a new one' do
          expect(citation_ticket.violation.images.ids.include?(@image.id)).to be false
        end
      end
    end

    context 'fail' do
      context 'unauthorized' do
        subject do
          put "/api/dashboard/parking/citation_tickets/#{citation_ticket.id}", params: valid_params
        end

        before { subject }

        it 'returns unauthorized error' do
          subject
          expect(json[:error]).to eq('Unauthorized')
        end

        it_behaves_like 'response_401'
      end

      context 'not allowed status transaction' do
        let(:valid_params) do
          {
           parking_violation: {
             status: 'sent_to_court',
             admin_id: manager.id
           }
          }
        end

        subject do
          put "/api/dashboard/parking/citation_tickets/#{citation_ticket.id}", headers: { Authorization: get_auth_token(admin) }, params: valid_params
        end

        before do
          subject
          citation_ticket.reload
        end

        it 'don\'t update status and return error message' do
          expect(json['errors'].present?).to be true
          expect(citation_ticket.status).to eq('unsettled')
        end
      end

      context 'when image size is more then 1.5MB' do
        let(:image) { fixture_base64_file_upload('spec/files/test_image.jpg') }
        let(:valid_params) do
          {
           citation_ticket: {
             status: 'settled',
             images: [image]
           }
          }
        end

        subject do
          put "/api/dashboard/parking/citation_tickets/#{citation_ticket.id}", headers: { Authorization: get_auth_token(admin) }, params: valid_params
        end

        before do
          subject
        end

        it 'does not upload image and returns error message' do
          expect(json[:errors][:image].present?).to be true
          expect(citation_ticket.violation.images.size).to eq(0)
        end
      end

      context 'when citation ticket does not exist' do
        subject do
          put '/api/dashboard/parking/citation_tickets/invalid_id', headers: { Authorization: get_auth_token(admin) }, params: valid_params
        end

        it_behaves_like 'response_404'
      end
    end
  end
end
