require 'rails_helper'

RSpec.describe Api::Dashboard::PlacesController, type: :request do
  let(:admin) { create(:admin, role: super_admin_role) }
  let(:parking_lot) { create(:parking_lot) }
  let(:parking_lot_place) do
    {
      name: 'Minsk Hotel',
      lat: 53.896622,
      lng: 27.55041,
      types: [
        'casino',
        'night_club',
        'lodging'
      ]
    }
  end

  describe 'GET #index' do
    before do
      allow(::Dashboard::Redis::RetrieveParkingLotPlaces).to receive(:call).and_return(parking_lot_place)
    end

    context 'success' do
      subject do
        get "/api/dashboard/parking_lots/#{parking_lot.id}/places", headers: { Authorization: get_auth_token(admin) }
      end

      before { subject }

      it_behaves_like 'response_200', :show_in_doc

      it 'returns all parking lot places' do
        expect(json[:places][:name]).to eq(parking_lot_place[:name])
      end
    end

    context 'fail' do
      context 'unauthorized' do
        subject do
          get "/api/dashboard/parking_lots/#{parking_lot.id}/places"
        end

        it_behaves_like 'response_401'
      end

      context 'when parking_lot not founded' do
        subject do
          get '/api/dashboard/parking_lots/invalid_lot_id/places', headers: { Authorization: get_auth_token(admin) }
        end

        it_behaves_like 'response_404'
      end
    end
  end
end
