module ParkingSessions
  class UpdateLpn < ApplicationInteraction
    object :object, class: ParkingSession
    string :lpn

    validates :lpn, presence: true

    validate do
      if !(lpn =~ /\A[A-Za-z0-9]+\z/)
        errors.add(:lpn, :invalid)
        throw(:abort)
      end
    end

    def execute
      object.update(ksk_plate_number: lpn)
      object.reload.logs.first.update(comment: I18n.t("parking/log.text.ksk_plate_number_changed"))

      unless object.plate_number_verified
        object.update(plate_number_verified: true)
        object.reload.logs.first.update(comment: I18n.t("parking/log.text.lpn_confirmed"))
      else
        object.logs.find_by(comment: I18n.t("parking/log.text.lpn_confirmed"))&.update(created_at: DateTime.now)
      end
    end

  end
end