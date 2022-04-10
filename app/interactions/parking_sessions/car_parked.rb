module ParkingSessions
  class CarParked < BaseEvent
    include Logging

    attr_reader :slot

    string :parking_slot_id

    validate :should_abort?

    set_callback :validate, :before, -> do
      return if session.present? # Avoid execute mutliple times when validations happen
      set_session
      initialize_session do |vehicle|
        {
          vehicle: vehicle,
          parking_lot: parking_lot,
          ai_plate_number: plate_number,
          ksk_plate_number: vehicle.plate_number || '',
          entered_at: Time.at(timestamp),
          uuid: uuid
        }
      end
      set_parking_slot
      set_parking_lot
    end

    def execute
      return if session_finished?

      if slot.occupied?
        Ai::ErrorReport.create(error_type: :park_on_occupied_space, parking_session: session, extra_data: {
          uuid: uuid,
          action: 'car_parked'.freeze
        })
        errors.add(:parking_slot_id, :occupied)
      else
        bind_session_and_slot
        if valid? && user = session.vehicle.user
          UserNotifier.car_parked(user, session)
          Ai::Parking::CheckOutTimeCounterWorker.increase_check_out_time(session)
        end
      end
    end

    # Notify if LPN is unrecognized when a car is parking between 7:00am and 7:00pm
    def alert_unrecognized_lpn?
      parking_lot_time_zone = parking_lot.time_zone
      if session.vehicle.plate_number.nil? && (Time.now.in_time_zone(parking_lot_time_zone).hour >= 7 && Time.now.in_time_zone(parking_lot_time_zone).hour < 19)
        return SLOT_NAME_TO_IGNORE.exclude?(parking_slot_id)
      end
      false
    end

    private

    def bind_session_and_slot
      ActiveRecord::Base.transaction do
        attributes = {
          parking_slot: slot,
          parked_at: Time.at(timestamp),
          ai_status: :parked,
          check_out: Time.at(timestamp + parking_lot.period)
        }

        if session.cancelled? # After a session is cancelled if decide to park again in another slot it should be able to do it
          attributes.merge!(status: :created)
        end

        if session.vehicle.user
          attributes.merge!(fee_applied: session.rate)
        end

        attributes.merge!(check_in: Time.at(timestamp)) if session.check_in.blank?

        unless session.update(attributes)
          errors.merge!(session.errors)
          raise ActiveRecord::Rollback
        end

        unless slot.update(status: :occupied)
          errors.merge!(slot.errors)
          raise ActiveRecord::Rollback
        end

        create_alert
        broadcast_to_parking_spaces
        Ai::Parking::GracePeriodViolationWorker.start_counter(session)
      end
    end

    def create_alert
      return if user.blank?
      transactional_create!(Alert, subject: session, user: session.vehicle.user)
    end

    def set_parking_slot
      unless @slot = (parking_lot.parking_slots.find_by(name: parking_slot_id))
        errors.add(:parking_slot_id, :not_found)
        throw(:abort)
      end
    end

    def broadcast_to_parking_spaces
      ActionCable.server.broadcast("parking_spaces_channel_#{parking_lot.id}",::Api::Dashboard::Parking::SlotSerializer.new(slot))
    end
  end
end
