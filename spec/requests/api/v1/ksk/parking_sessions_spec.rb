require 'rails_helper'

describe Api::V1::Ksk::ParkingSessionsController, type: :request do
  let!(:auth_token) { create(:ksk_token).value }

  describe 'GET #index' do
    let!(:session) { create(:parking_session, check_out: nil) }

    context 'by plate number' do
      context 'success' do
        subject do
          get '/api/v1/ksk/parking_sessions',
              headers: { Authorization: auth_token },
              params: { plate_number: session.vehicle.plate_number.upcase }
        end

        it_behaves_like 'response_200'

        it 'returns an empty LPN if ksk_plate_number contains symbols' do
          session.update(ksk_plate_number: 'ABC:123*')
          subject
          expect(json['vehicle']['plate_number']).to be_empty
        end

        it 'returns LPN from ksk_plate_number' do
          lpn = 'ABC123'
          session.update(ksk_plate_number: lpn)
          subject
          expect(json['vehicle']['plate_number']).to eq(lpn)
        end
      end

      context 'fail' do
        subject do
          get '/api/v1/ksk/parking_sessions',
              headers: { Authorization: auth_token },
              params: { plate: 'invalid' }
        end

        it_behaves_like 'response_404', :show_in_doc
      end
    end

    context 'by parking slot' do
      context 'success' do
        subject do
          get '/api/v1/ksk/parking_sessions',
              headers: { Authorization: auth_token },
              params: { parking_slot_id: session.parking_slot.name }
        end

        it_behaves_like 'response_200', :show_in_doc

        it 'has required attributes' do
          subject
          [
            :id,
            :check_in,
            :check_out,
            :lot,
            :slot,
            :status,
            :total_price,
            :paid
          ].each do |a|
            expect(json.has_key?(a)).to eq(true)
          end
        end
      end
    end
  end

  describe 'PUT #confirm' do
    let!(:session) { create(:parking_session) }
    let!(:next_check_out) { 2.hours.from_now.to_i }

    context 'success' do
      subject do
        Sidekiq::Testing.fake! do
          put "/api/v1/ksk/parking_sessions/#{session.id}/confirm",
              headers: { Authorization: auth_token },
              params: { parking_session: { check_out: next_check_out } }
        end
      end

      it_behaves_like 'response_200'

      it 'updates session' do
        subject
        expect(session.reload.check_out.present?).to eq(true)
        expect(session.confirmed?).to eq(true)
      end

      it 'answers with updated session' do
        subject
        expect(json[:check_out]).to eq(next_check_out)
        expect(json[:paid]).to eq(true)
      end

      it 'updates vehicle LPN when ksk_plate_number is different' do
        lpn = 'abc123z'
        session.update(ksk_plate_number: lpn)
        subject
        session.reload
        expect(session.vehicle.plate_number).to eq(lpn)
      end
    end
  end

  describe 'GET #update_lpn' do
    let!(:session) { create(:parking_session) }

    context 'success' do

      subject do
        put "/api/v1/ksk/parking_sessions/#{session.id}/lpn",
            headers: { Authorization: auth_token },
            params: { lpn: 'ABC123' }
      end

      it 'changes ksk_plate_number' do
        ksk_plate_number = session.ksk_plate_number
        subject
        session.reload
        expect(ksk_plate_number).not_to eq(session.ksk_plate_number)
        expect(session.vehicle.plate_number).to eq(ksk_plate_number)
      end
    end

    context 'failed' do

      subject do
        put "/api/v1/ksk/parking_sessions/#{session.id}/lpn",
          headers: { Authorization: auth_token },
            params: @params
      end

      it 'doesn\'t allow empty lpn' do
        @params = { lpn: '' }
        subject
        expect(json[:errors][:lpn].present?).to eq(true)
      end

      it 'should not allow empty lpn' do
        @params = {}
        subject
        expect(json[:errors][:lpn].present?).to eq(true)
      end
    end

  end
end