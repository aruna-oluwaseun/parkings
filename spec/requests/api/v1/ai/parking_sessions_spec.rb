require 'rails_helper'

RSpec.describe Api::V1::Ai::ParkingSessionsController, type: :request do
  let!(:auth_token) { create(:ai_token).value }
  let!(:parking_lot) { create(:parking_lot, :with_rules, :with_camera) }

  describe 'GET #index' do
    let!(:slots) { create_list(:parking_slot, 4, parking_lot: parking_lot) }
    let!(:parking_sessions) { create_list(:parking_session, 4, parking_lot: parking_lot, parking_slot: nil) }
    let!(:finished_sessions) { create_list(:parking_session, 4, parking_lot: parking_lot, status: :finished) }

    before(:each) do
      slots.first(2).each_with_index do |slot, index|
        parking_sessions[index].update!(parking_slot: slot)
        slot.update!(status: :occupied)
      end
    end

    context 'success: vehicle recognized' do
      subject do
        get "/api/v1/ai/parking_sessions", headers: { Authorization: auth_token }, params: { parking_lot_id: parking_lot.id }
      end

      it_behaves_like 'response_200', :show_in_doc

      it 'should have 4 sessions and 4 slots' do
        subject
        expect(json[:sessions].size).to eq(4)
        expect(json[:slots].size).to eq(4)
      end

      it 'should contains following fields' do
        subject
        [
          :uuid,
          :parking_slot_id,
        ].each do |a|
          expect(json['sessions'].sample.with_indifferent_access.has_key?(a)).to eq(true)
        end
      end
    end
  end

  describe 'POST #car_entrance' do
    subject do
      post '/api/v1/ai/parking_sessions/car_entrance', headers: { Authorization: auth_token }, params: car_entrance_payload
    end

    context 'sanitize plate number' do
      let!(:plate_number) { '1A-B[C]D2' }
      subject do
        post '/api/v1/ai/parking_sessions/car_entrance', headers: { Authorization: auth_token }, params: car_entrance_payload(plate_number)
      end

      it_behaves_like 'response_201', :show_in_doc

      it 'should saved sanitized plate number' do
        subject
        parking_session = ParkingSession.last
        sanitized_plate_number = plate_number.remove_non_alphanumeric
        expect(parking_session.ai_plate_number).to eq(plate_number)
        expect(parking_session.vehicle.plate_number).to eq(sanitized_plate_number&.downcase)
      end
    end

    context 'success' do
      after do
        expect(PaperTrail::Version.last.comment).to eq(I18n.t("parking/log.text.car_entrance", lot_name: parking_lot.name))
      end

      it_behaves_like 'response_201', :show_in_doc
    end

    context 'failure due to duplicated session'  do
      before do
        post '/api/v1/ai/parking_sessions/car_entrance', headers: { Authorization: auth_token }, params: car_entrance_payload
      end

      it_behaves_like 'response_422', :show_in_doc

      it 'should create a error report' do
        subject
        expect(Ai::ErrorReport.count).to eq(1)
        expect(Ai::ErrorReport.last.error_type.to_sym).to eq(:duplicated_session)
      end
    end

    context 'failure due to lpn or image not present' do
      subject do
        post '/api/v1/ai/parking_sessions/car_entrance', headers: { Authorization: auth_token }, params: car_entrance_payload('', false)
      end

      it 'should create a error report' do
        subject
        expect(Ai::ErrorReport.count).to eq(1)
        expect(Ai::ErrorReport.last.error_type.to_sym).to eq(:lpn_or_img_not_present)
      end
    end

    context 'create a report with an lpn unrecognized' do
      subject do
        post '/api/v1/ai/parking_sessions/car_entrance', headers: { Authorization: auth_token }, params: car_entrance_payload(nil)
      end

      it 'should create a error report' do
        subject
        expect(Ai::ErrorReport.count).to eq(1)
        expect(Ai::ErrorReport.last.error_type.to_sym).to eq(:lpn_unrecognized)
      end
    end

  end

  describe 'POST #car_parked' do
    let!(:parking_session) { create(:parking_session, parking_lot: parking_lot, parking_slot: nil) }
    let!(:free_slot) { create(:parking_slot, parking_lot: parking_lot, status: :free) }

    context 'success' do
      subject do
        Sidekiq::Testing.fake! do
          post '/api/v1/ai/parking_sessions/car_parked', headers: { Authorization: auth_token }, params: car_parked_payload(parking_session, free_slot)
        end
      end

      after do
        expect(PaperTrail::Version.where(item_type: 'ParkingSession').last.comment).to eq(I18n.t("parking/log.text.car_parked", slot_name: free_slot.name))
      end

      it_behaves_like 'response_201', :show_in_doc

      context 'Generate error report due to unrecognized entrance' do
        before do
          Sidekiq::Testing.fake! do
            post '/api/v1/ai/parking_sessions/car_parked', headers: { Authorization: auth_token }, params: car_parked_payload(ParkingSession.new(uuid: 'abcxyz'), free_slot, { plate_number: 'ABC123' })
          end
        end

        it 'should create a error report' do
          expect(Ai::ErrorReport.count).to eq(1)
          expect(Ai::ErrorReport.last.error_type.to_sym).to eq(:car_entrance_unrecognized)
        end
      end
    end

    context 'failure due to occupied slot' do
      before do
        Sidekiq::Testing.fake! do
          post '/api/v1/ai/parking_sessions/car_parked', headers: { Authorization: auth_token }, params: car_parked_payload(parking_session, free_slot)
        end
        Sidekiq::Testing.fake! do
          post '/api/v1/ai/parking_sessions/car_parked', headers: { Authorization: auth_token }, params: car_parked_payload(parking_session, free_slot)
        end
      end

      it 'should create a error report' do
        expect(Ai::ErrorReport.count).to eq(1)
        expect(Ai::ErrorReport.last.error_type.to_sym).to eq(:park_on_occupied_space)
      end
    end

    context 'failure due to duplicated session' do
      before do
        Sidekiq::Testing.fake! do
          post '/api/v1/ai/parking_sessions/car_parked', headers: { Authorization: auth_token }, params: car_parked_payload(parking_session, free_slot)
        end
        Sidekiq::Testing.fake! do
          post '/api/v1/ai/parking_sessions/car_parked', headers: { Authorization: auth_token }, params: car_parked_payload(ParkingSession.new(uuid: 'abcxyz'), free_slot, { plate_number: parking_session.vehicle.plate_number })
        end
      end

      it 'should create a error report' do
        expect(Ai::ErrorReport.count).to eq(1)
        expect(Ai::ErrorReport.last.error_type.to_sym).to eq(:duplicated_session)
      end
    end
  end

  describe 'POST #car_left' do
    let!(:occupied_slot) { create(:parking_slot, parking_lot: parking_lot, status: :occupied) }
    let!(:parking_session) { create(:parking_session, parking_lot: parking_lot, parking_slot_id: occupied_slot.id) }

    context 'success' do
      subject do
        post '/api/v1/ai/parking_sessions/car_left', headers: { Authorization: auth_token }, params: car_left_payload(parking_session)
      end

      after do
        expect(PaperTrail::Version.last.comment).to eq(I18n.t("parking/log.text.car_left", slot_name: occupied_slot.name))
      end

      it_behaves_like 'response_201', :show_in_doc
    end
  end

  describe 'POST #car_exit' do

    context 'success' do
      let!(:parking_session) { create(:parking_session, parking_lot: parking_lot) }

      subject do
        post '/api/v1/ai/parking_sessions/car_exit', headers: { Authorization: auth_token }, params: car_exit_payload(parking_session)
      end

      after do
        expect(PaperTrail::Version.last.comment).to eq(I18n.t("parking/log.text.car_exit", lot_name: parking_session.parking_lot.name))
      end

      it_behaves_like 'response_201', :show_in_doc

      context 'Generate report' do
        let!(:parking_session) { create(:parking_session, parking_lot: parking_lot, uuid: 'ABCXYZ', ai_status: :parked) }

        it 'should create a error report' do
          subject
          expect(Ai::ErrorReport.count).to eq(1)
          expect(Ai::ErrorReport.last.error_type.to_sym).to eq(:car_leaving_slot_unrecognized)
        end
      end

    end

  end

  describe 'POST #violation_commited' do
    let!(:parking_session) { create(:parking_session) }

    context 'success' do
      subject do
        post '/api/v1/ai/parking_sessions/violation_commited',
             headers: { Authorization: auth_token },
             params: violation_commited_payload(parking_session).merge(parking_lot_id: parking_lot.id)
      end

      it_behaves_like 'response_201', :show_in_doc
    end
  end

  describe 'AI Car flow' do
    let!(:slots) { create_list(:parking_slot, 4, parking_lot: parking_lot) }

    describe 'Car with user' do
      let!(:vehicle) { create(:vehicle, plate_number: 'plate_number') }

      describe '#car_entrance, #car_parked, #car_left and #car_exit' do
        before do
          car_entered
        end

        after do
          @slot.reload
          expect(@slot.status).to eq('free')
        end

        it 'car left soon' do
          car_parked
          car_left_soon
          car_exit
          expect(Parking::VehicleRule.count).to eq(0)
        end

        it 'car left next day' do
          car_parked
          car_left_in_24_hours
          car_exit
          expect(Parking::VehicleRule.count).to eq(1)
          expect(Parking::Violation.first.rule.name).to eq("unpaid")
        end
      end

      it '#car_entrance, #car_left and #car_exit' do
        car_entered
        post '/api/v1/ai/parking_sessions/car_left', headers: { Authorization: auth_token }, params: car_left_payload(@parking_session)
        expect(JSON.parse(response.body)['errors'].present?).to eq(true)
        @parking_session.reload
        expect(@parking_session.ai_status).to eq('entered')
        expect(@parking_session.status).to eq('created')
        car_exit
        expect(Parking::VehicleRule.count).to eq(0)
      end

      it '#car_entrance and #car_exit' do
        car_entered
        car_exit
        expect(Parking::VehicleRule.count).to eq(0)
      end
    end

    describe 'Car without user' do
      describe '#car_entrance, #car_parked, #car_left and #car_exit' do
        before do
          car_entered
        end

        after do
          @slot.reload
          expect(@slot.status).to eq('free')
        end

        it 'car left soon' do
          # In order to respect the perform_in action with sidekiq on tests
          Sidekiq::Testing.fake! do
            car_parked
          end
          car_left_soon
          car_exit
          expect(Parking::VehicleRule.count).to eq(0)
        end

        it 'car left next day' do
          car_parked
          car_left_in_24_hours
          car_exit
          expect(Parking::VehicleRule.count).to eq(1)
          expect(Parking::Violation.first.rule.name).to eq("exceeding_grace_period")
          expect(Parking::Violation.second.rule.name).to eq("unpaid")
        end

        describe 'car parked and decide to parked somewhere else after' do

          it '#car_parked, #car_left, #car_parked, #car_left (leave both slots immediately)' do
            Sidekiq::Testing.fake! do
              car_parked
            end
            car_left_soon
            @slot_2 = ParkingSlot.second
            Sidekiq::Testing.fake! do
              car_parked(@slot_2)
            end
            car_left_soon(@slot_2)
            car_exit
            expect(Parking::VehicleRule.count).to eq(0)
          end

          it '#car_parked, #car_left, #car_parked, #car_left (leave first slots immediately and stay on second one)' do
            Sidekiq::Testing.fake! do
              car_parked
            end
            car_left_soon
            @slot_2 = ParkingSlot.second
            car_parked(@slot_2)
            car_left_in_24_hours(@slot_2)
            car_exit
            expect(Parking::VehicleRule.count).to eq(1)
            expect(Parking::Violation.first.rule.name).to eq("exceeding_grace_period")
            expect(Parking::Violation.second.rule.name).to eq("unpaid")
          end

          it '#car_parked, #car_left, #car_parked, #car_left (leave first slot after it\'s done)' do
            pending "This scenario is not possible yet"
            car_parked
            car_left_in_24_hours
            @slot_2 = ParkingSlot.second
            Sidekiq::Testing.fake! do
              car_parked(@slot_2)
            end
            car_left_soon(@slot_2)
            car_exit
            expect(Parking::VehicleRule.count).to eq(2)
            expect(Parking::Violation.first.rule.name).to eq("exceeding_grace_period")
            expect(Parking::Violation.second.rule.name).to eq("unpaid")
          end

        end

      end

      describe '#car_entrance, #car_parked, ksk#session#index (later), #car_left and #car_exit' do
        let!(:ksk_token) { create(:ksk_token).value }

        before do
          car_entered
          car_parked
        end

        after do
          @slot.reload
          expect(@slot.status).to eq('free')
        end

        it 'car tries to confirm session after ticket approved' do
          Parking::Ticket.first.update(status: :approved)
          get_session_from_ksk
          session_ksk = JSON.parse(response.body)
          expect(session_ksk['error'].present?).to eq(true)
          travel_to(Time.current + @parking_session.parked) do
            car_left_soon(@slot, "created")
            @parking_session.reload
            expect(@parking_session.kiosk_id).to eq(nil)
            car_exit
            expect(Parking::VehicleRule.count).to eq(1)
            expect(Parking::Violation.first.rule.name).to eq("exceeding_grace_period")
            expect(Parking::Violation.second.rule.name).to eq("unpaid")
          end
        end

        it 'car tries to confirm session before ticket approved' do
          Sidekiq::Testing.fake! do
            get_session_from_ksk
            session_ksk = JSON.parse(response.body)
            expect(session_ksk['id']).to eq(@parking_session.id)
            confirm_on_ksk
          end
          car_left_soon(@slot, 'confirmed')
          @parking_session.reload
          expect(@parking_session.kiosk_id).to eq(Kiosk.first.id)
          car_exit
          expect(Parking::VehicleRule.count).to eq(1)
          expect(Parking::Violation.first.rule.name).to eq("exceeding_grace_period")
        end

      end

      describe '#car_entrance, #car_parked, ksk#confirm, #car_left and #car_exit' do
        let!(:ksk_token) { create(:ksk_token).value }

        before do
          car_entered
        end

        after do
          @slot.reload
          expect(@slot.status).to eq('free')
        end

        it 'car leaves after confirm' do
          Sidekiq::Testing.fake! do
            car_parked
            get_session_from_ksk
            session_ksk = JSON.parse(response.body)
            expect(session_ksk['id']).to eq(@parking_session.id)
            confirm_on_ksk
          end
          post '/api/v1/ai/parking_sessions/car_left', headers: { Authorization: auth_token }, params: car_left_payload(@parking_session)
          @parking_session.reload
          expect(@parking_session.kiosk_id).to eq(Kiosk.first.id)
          expect(@parking_session.ai_status).to eq('left')
          expect(@parking_session.status).to eq('confirmed') # It's already confirmed
          car_exit
          expect(Parking::VehicleRule.count).to eq(0)
        end

        it 'car left to exact time' do
          Sidekiq::Testing.fake! do
            car_parked
            get_session_from_ksk
            session_ksk = JSON.parse(response.body)
            expect(session_ksk['error'].present?).to eq(false)
            confirm_on_ksk
          end
          travel_to(Time.current + 45.minutes) do
            post '/api/v1/ai/parking_sessions/car_left', headers: { Authorization: auth_token }, params: car_left_payload(@parking_session)
          end
          @parking_session.reload
          expect(@parking_session.ai_status).to eq('left')
          expect(@parking_session.status).to eq('confirmed')
          car_exit
          expect(Parking::VehicleRule.count).to eq(0)
        end

        it 'car left next day' do
          Sidekiq::Testing.fake! do
            car_parked
            get_session_from_ksk
            session_ksk = JSON.parse(response.body)
            expect(session_ksk['error'].present?).to eq(false)
          end
          confirm_on_ksk
          travel_to(Time.current + 24.hours) do
            post '/api/v1/ai/parking_sessions/car_left', headers: { Authorization: auth_token }, params: car_left_payload(@parking_session)
          end
          @parking_session.reload
          expect(@parking_session.ai_status).to eq('left')
          expect(@parking_session.status).to eq('confirmed')
          car_exit
          expect(Parking::VehicleRule.count).to eq(1)
          expect(Parking::Violation.first.rule.name).to eq("parking_expired")
        end
      end

      it '#car_entrance and #car_exit' do
        car_entered
        car_exit
        expect(Parking::VehicleRule.count).to eq(0)
      end

      describe "It doesn't detect entrance of a car" do
        let!(:uuid) { SecureRandom.hex(8) }
        let!(:plate_number) { Faker::Car.number }
        before do
          @slot = ParkingSlot.first
        end

        describe 'It does detect the LPN' do
          let!(:ksk_token) { create(:ksk_token).value }

          after do
            @slot.reload
            expect(@slot.status).to eq('free')
          end

          it '#car_parked #car_left and #car_exit' do
            post '/api/v1/ai/parking_sessions/car_parked', headers: { Authorization: auth_token }, params: car_parked_payload(OpenStruct.new(uuid: uuid), @slot, { plate_number:  plate_number })
            @parking_session = ParkingSession.find(json['session_id'])
            @slot.reload
            expect(@parking_session.ai_status).to eq('parked')
            expect(@parking_session.status).to eq('created')
            expect(@slot.status).to eq('occupied')
            car_left_in_24_hours
            car_exit
            expect(Parking::VehicleRule.count).to eq(1)
            expect(Parking::Violation.first.rule.name).to eq("exceeding_grace_period")
            expect(Parking::Violation.second.rule.name).to eq("unpaid")
          end

          it '#car_parked, ksk#confirm, #car_left (24 hours) and #car_exit' do
            Sidekiq::Testing.fake! do
              post '/api/v1/ai/parking_sessions/car_parked', headers: { Authorization: auth_token }, params: car_parked_payload(OpenStruct.new(uuid: uuid), @slot, { plate_number:  plate_number })
              @parking_session = ParkingSession.find(json['session_id'])
              @slot.reload
              expect(@parking_session.ai_status).to eq('parked')
              expect(@parking_session.status).to eq('created')
              expect(@slot.status).to eq('occupied')
              get_session_from_ksk
              session_ksk = JSON.parse(response.body)
              expect(session_ksk['error'].present?).to eq(false)
            end
            confirm_on_ksk
            car_left_in_24_hours(@slot, 'confirmed')
            car_exit
            expect(Parking::VehicleRule.count).to eq(1)
            expect(Parking::Violation.first.rule.name).to eq("parking_expired")
          end

          it '#car_left and #car_exit' do
            post '/api/v1/ai/parking_sessions/car_left', headers: { Authorization: auth_token }, params: car_left_payload(OpenStruct.new(uuid: uuid), { plate_number:  plate_number })
            expect(json[:errors][:session].present?).to eq(true)
            @parking_session = ParkingSession.last
            expect(@parking_session.ai_status).to eq('left')
            expect(@parking_session.status).to eq('created')
            car_exit
          end
        end

        describe 'It doesn\'t detect the LP or image' do
          it '#car_parked' do
            post '/api/v1/ai/parking_sessions/car_parked', headers: { Authorization: auth_token }, params: car_parked_payload(OpenStruct.new(uuid: uuid), @slot)
            expect(json[:errors][:base].present?).to eq(true)
          end
          it '#car_left' do
            post '/api/v1/ai/parking_sessions/car_left', headers: { Authorization: auth_token }, params: car_left_payload(OpenStruct.new(uuid: uuid))
            expect(json[:errors][:base].present?).to eq(true)
          end
          it '#car_exit' do
            post '/api/v1/ai/parking_sessions/car_exit', headers: { Authorization: auth_token }, params: car_exit_payload(OpenStruct.new(uuid: uuid))
            expect(json[:errors][:base].present?).to eq(true)
          end
        end
      end
    end
    describe "AI errors" do
      describe "Not allow further actions after exit" do
        it '#car_entrance, #car_exit and #car_exit' do
          car_entered
          post '/api/v1/ai/parking_sessions/car_exit', headers: { Authorization: auth_token }, params: car_exit_payload(@parking_session)
          @parking_session.reload
          expect(@parking_session.ai_status).to eq('exited')
          expect(@parking_session.status).to eq('finished')
          expect(Parking::VehicleRule.count).to eq(0)
          exit_at = @parking_session.exit_at
          result = post '/api/v1/ai/parking_sessions/car_exit', headers: { Authorization: auth_token }, params: car_exit_payload(@parking_session)
          @parking_session.reload
          expect(response.status).to eq(422)
          expect(@parking_session.exit_at).to eq(exit_at)
        end
      end
    end
  end
end

def car_entered
  post '/api/v1/ai/parking_sessions/car_entrance', headers: { Authorization: auth_token }, params: car_entrance_payload
  @parking_session = ParkingSession.find(json['session_id'])
  @slot = ParkingSlot.first
  expect(@parking_session.ai_status).to eq('entered')
  expect(@parking_session.status).to eq('created')
end

def car_parked(slot = @slot, waited_status = 'created')
  post '/api/v1/ai/parking_sessions/car_parked', headers: { Authorization: auth_token }, params: car_parked_payload(@parking_session, slot)
  @parking_session.reload
  slot.reload
  expect(@parking_session.ai_status).to eq('parked')
  expect(@parking_session.status).to eq(waited_status)
  expect(slot.status).to eq('occupied')
end

def car_left_soon(slot = @slot, waited_status = 'cancelled')
  post '/api/v1/ai/parking_sessions/car_left', headers: { Authorization: auth_token }, params: car_left_payload(@parking_session)
  slot.reload
  @parking_session.reload
  expect(@parking_session.ai_status).to eq('left')
  expect(@parking_session.status).to eq(waited_status)
  expect(slot.status).to eq('free')
end

def car_left_in_24_hours(slot = @slot, waited_status = 'created')
  travel_to(Time.current + 24.hours) do
    post '/api/v1/ai/parking_sessions/car_left', headers: { Authorization: auth_token }, params: car_left_payload(@parking_session)
    slot.reload
    @parking_session.reload
    expect(@parking_session.ai_status).to eq('left')
    expect(@parking_session.status).to eq(waited_status)
    expect(slot.status).to eq('free')
  end
end

def car_exit
  post '/api/v1/ai/parking_sessions/car_exit', headers: { Authorization: auth_token }, params: car_exit_payload(@parking_session)
  @parking_session.reload
  expect(@parking_session.ai_status).to eq('exited')
  expect(@parking_session.status).to eq('finished')
end

def get_session_from_ksk(slot = @slot)
  get "/api/v1/ksk/parking_sessions/", headers: { Authorization: ksk_token }, params: { parking_lot_id: @parking_session.parking_lot.id, parking_slot_id: slot.name }, as: :json
end

def confirm_on_ksk
  check_out = 45.minutes.from_now.to_i
  put "/api/v1/ksk/parking_sessions/#{@parking_session.id}/confirm", headers: { Authorization: ksk_token }, params: { parking_session: { check_out: check_out } }, as: :json
  @parking_session.reload
  expect(@parking_session.check_out).to eq(Time.at(check_out))
  expect(@parking_session.status).to eq('confirmed')
end
