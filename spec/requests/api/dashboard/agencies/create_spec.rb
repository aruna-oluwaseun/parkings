require 'rails_helper'

RSpec.describe Api::Dashboard::AgenciesController, type: :request do
  let!(:admin) { create(:admin, role: super_admin_role) }
  let!(:manager) { create(:admin, role: manager_role) }
  let!(:officers) { create_list(:admin, 2, role: officer_role) }
  let!(:parking_admin) { create(:admin, role: parking_admin_role) }
  let(:parking_lot) { create(:parking_lot) }
  let(:agency) { Agency.last }
  let(:agency_type) { create(:agency_type) }
  let(:location) { Location.where(subject: agency) }
  
  let(:valid_params) do
    {
      email: Faker::Internet.email,
      name: Faker::Company.name,
      agency_type_id: agency_type.id,
      location: {
        country: Faker::Address.country,
        city: Faker::Address.city,
        state: Faker::Address.state,
        building: Faker::Address.building_number,
        street: Faker::Address.street_name,
        zip: Faker::Address.zip(Faker::Address.state_abbr),
        ltd: Faker::Address.latitude,
        lng: Faker::Address.longitude
      },
      phone: Faker::Phone.number,
      manager_id: manager.id,
      officer_ids: [officers.map(&:id)],
      parking_lot_ids: [parking_lot.id],
      avatar: fixture_base64_file_upload('spec/files/test.jpg')
    }
  end

  describe 'POST #create' do
    context 'success' do
      subject do
        post '/api/dashboard/agencies', headers: { Authorization: get_auth_token(admin) }, params: {
          agency: valid_params
        }
      end

      it_behaves_like 'response_201', :show_in_doc

      it 'should create new agency' do
        expect { subject }.to change(Agency, :count).by(1)
      end

      it 'should create new location' do
        subject
        expect(agency.reload.location).to be_present
      end

      it 'should assign new agency to parking_lot' do
        subject
        expect(agency.manager).to eq(manager)
        expect(Set.new(agency.officers)).to eq(Set.new(officers))
      end

      it 'should assign new agency to parking_lot' do
        subject
        expect(agency.parking_lots).to include(parking_lot)
      end

      it 'should send mails' do
        expect(AdminMailer).to receive(:subject_created)
          .and_return( double("AdminMailer", deliver_later: true) ).once
        expect(AdminMailer).to receive(:assigned_to_agency)
          .and_return( double("AdminMailer", deliver_later: true) ).exactly(3).times
        subject
      end
    end

    context 'success: without officers, phone, avatar' do
      context 'officers empty' do
        subject do
          params = valid_params
          post '/api/dashboard/agencies', headers: { Authorization: get_auth_token(admin) }, params: {
            agency: params.except(:officers, :phone, :avatar)
          }
        end

        it_behaves_like 'response_201'
      end

      context 'officers nil' do
        subject do
          params = valid_params
          params[:officers] = nil
          post '/api/dashboard/agencies', headers: { Authorization: get_auth_token(admin) }, params: {
            agency: params.except(:phone, :avatar)
          }
        end

        it_behaves_like 'response_201'
      end
    end

    context 'fail: empty params' do
      subject do
        post '/api/dashboard/agencies', headers: { Authorization: get_auth_token(admin) }, params: {}
      end

      it_behaves_like 'response_422', :show_in_doc
    end

    context 'fail: invalid params: invalid role' do
      subject do
        params = valid_params
        params[:manager_id] = parking_admin.id
        post '/api/dashboard/agencies', headers: { Authorization: get_auth_token(admin) }, params: {
          agency: params
        }
      end

      it_behaves_like 'response_422', :show_in_doc
    end

    context 'when agency type is not founded' do
      let(:invalid_params) do
        {
          email: Faker::Internet.email,
          name: Faker::Company.name,
          agency_type_id: ' ',
          location: {
            country: Faker::Address.country,
            city: Faker::Address.city,
            state: Faker::Address.state,
            building: Faker::Address.building_number,
            street: Faker::Address.street_name,
            zip: Faker::Address.zip(Faker::Address.state_abbr),
            ltd: Faker::Address.latitude,
            lng: Faker::Address.longitude
          },
          manager_id: manager.id
        }
      end

      before do
        post '/api/dashboard/agencies', headers: { Authorization: get_auth_token(admin) }, params: { agency: invalid_params }
      end

      it 'returns error message' do
        expect(json[:errors][:agency_type_id].present?).to be true
      end
    end
  end
end
