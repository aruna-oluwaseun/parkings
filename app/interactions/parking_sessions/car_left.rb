module ParkingSessions
  class CarLeft < BaseEvent
    include Logging

    attr_reader :slot

    validate :should_abort?

    set_callback :validate, :before, -> do
      return if session.present? # Avoid execute mutliple times when validations happen
      set_session
      initialize_session do |vehicle|
        {
          vehicle: vehicle,
          parking_lot: parking_lot,
          uuid: uuid,
          ai_plate_number: plate_number,
          ksk_plate_number: vehicle.plate_number || '',
          entered_at: Time.at(timestamp),
          left_at: Time.at(timestamp),
          ai_status: :left
        }
      end
      set_parking_lot
    end

    def execute
      return if session_finished? || !session_parked? || session_permanent?
      @slot = session.parking_slot

      if slot.free?
        errors.add(:parking_slot_id, :free) and return
      end

      update_session_and_slot
      broadcast_to_parking_spaces
      return if errors.present?
      return unless session.user
      UserNotifier.car_left(session.user, session)

      if session_cancelled?
        UserNotifier.session_cancelled(session.user, session)
      end
    end

    private

    def session_cancelled?
      (session.check_in + session.parked > Time.zone.now) && !session.confirmed?
    end

    def session_parked?
      if session.parking_slot.blank?
        Ai::ErrorReport.create( error_type: :session_not_parked, parking_session: ParkingSession.find_by(uuid: uuid), extra_data: {
          uuid: session.uuid,
          action: self.class.name.demodulize.underscore
        })
        errors.add(:session, :not_parked)
        return false
      end
      true
    end

    def update_session_and_slot
      ActiveRecord::Base.transaction do
        slot.free!

        if slot.invalid?
          errors.merge!(slot.errors)
          raise ActiveRecord::Rollback
        end

        attributes = { left_at: Time.at(timestamp), ai_status: :left }

        if session_cancelled?
          attributes.merge!(status: :cancelled, fee_applied: nil)
        end

        unless session.update(attributes)
          errors.merge!(session.errors)
          raise ActiveRecord::Rollback
        end

        archive_session
        pending_alerts
      end
    end

    def broadcast_to_parking_spaces
      ActionCable.server.broadcast("parking_spaces_channel_#{parking_lot.id}",::Api::Dashboard::Parking::SlotSerializer.new(slot))
    end

    def pending_alerts
      object.alerts.where(status: :opened).each do |alert|
        transactional_update!(alert, status: :pending)
      end
    end

    def archive_session
      return unless session.user
      Parking::History.create(parking_session: session, user: session.user)
    end
  end
end
