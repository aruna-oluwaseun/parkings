module ParkingSessions
  class CarEntrance < BaseEvent
    include Logging

    validate do
      # if AI doesn't specify one of following parameters - we shouldn't save session
      unless plate_number.present? || vehicle_images.any?
        ::Ai::ErrorReport.create(error_type: :lpn_or_img_not_present, extra_data: {
          uuid: uuid,
          action: 'car_entrance'
        })
        errors.add(:base, :need_more_details)
        throw(:abort)
      end
    end

    def execute
      ActiveRecord::Base.transaction do
        @vehicle = set_vehicle
        raise ActiveRecord::Rollback unless car_session_unique?
        create_session
        save_vehicle_images
        compose(Parking::VehicleRules::Check, vehicle: vehicle)
      end

      if invalid?
        # Because it does a rollback if session is not unique so we recheck this again
        if active_session = ParkingSession.where(vehicle_id: vehicle.id).where.not(status: :finished).last
          Ai::ErrorReport.create(error_type: :duplicated_session, parking_session: active_session, extra_data: {
            uuid: uuid,
            action: self.class.name.demodulize.underscore
          })
        end
        return
      end

      if vehicle.plate_number.present?
        notify_user
      else
        notify_admin
      end
    end

    def to_model
      session.reload
    end

    private

    def create_session
      attrs = {
        entered_at: Time.at(timestamp),
        vehicle: vehicle,
        ai_status: :entered,
        parking_lot: parking_lot,
        ai_plate_number: plate_number,
        ksk_plate_number: vehicle.plate_number || '',
        uuid: uuid
      }

      @session = transactional_create!(ParkingSession, attrs)
    end

    def notify_user
      if user = vehicle.user
        UserNotifier.car_entrance(user, session)
      end
    end

    def notify_admin
      ParkingAdminMailer.unrecognized_entrance(parking_lot).deliver_later
    end
  end
end
