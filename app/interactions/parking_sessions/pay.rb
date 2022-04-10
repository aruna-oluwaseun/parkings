module ParkingSessions
  class Pay < ::ApplicationInteraction
    include ApplicationHelper

    object :object, class: ParkingSession
    string :gateway, default: nil

    attr_reader :payment_info, :amount, :customer, :wallet, :amount, :parking_session_payment

    set_callback :validate, :before, -> do
      if object.user
        @customer = object.user
        @wallet = @customer.wallet
      end
      @payment_info = object.payment_info
      @amount = payment_info.unpaid
    end

    validate :user_has_enough_money?, :parking_session_paid?

    def execute
      if gateway
        @parking_session_payment = object.payments.create(amount: amount, status: :success, payment_method: :wallet)
        wallet.update(amount: wallet.amount - amount)
        resolve_alert
      else
        # temporary solution (mock payment) This should happen when request is coming from kiosk app
        @parking_session_payment = object.payments.create(amount: payment_info.pay, status: :success, payment_method: :cash)
        vehicle = Vehicle.find_by(plate_number: object.ksk_plate_number&.remove_non_alphanumeric&.downcase)
        
        if vehicle.present? && vehicle.id != object.vehicle.id
          object.update(vehicle: vehicle)
          object.reload.logs.first.update(comment: I18n.t("parking/log.text.vehicle_association_changed"))
        else
          object.vehicle.update(plate_number: object.ksk_plate_number)
        end
      end

      if parking_session_payment.invalid?
        errors.merge!(parking_session_payment.errors)
      else
        notify_user
        broadcast_to_parking_spaces
      end
    end

    private

    # Notify dashboard that a session was paid
    def broadcast_to_parking_spaces
      ActionCable.server.broadcast("parking_spaces_channel_#{object.parking_lot.id}",::Api::Dashboard::Parking::SlotSerializer.new(object.parking_slot))
    end

    def notify_user
      return unless user = object.user

      set_payment_receipt_message(parking_session_payment.id)
      send_payment_receipt(parking_session_payment.id)
      WalletMailer.almost_empty(user) if user.wallet.amount <= 100 # wallet amount stores in cents
    end

    def resolve_alert
      return if object.user.blank?
      object.alerts.where(type: :parking_confirmation, status: :opened).each do |alert|
        transactional_update!(alert, status: :resolved)
      end
    end

    def user_has_enough_money?
      return unless object.user

      if wallet.amount < payment_info.unpaid
        errors.add(:payment, :not_enough_money)
        throw(:abort)
      end
    end

    def parking_session_paid?
      if payment_info.paid?
        errors.add(:payment, :already_paid)
        throw(:abort)
      end
    end

    def send_payment_receipt(parking_session_payment_id)
      UserMailer.payment_receipt({
        session_id: object.id,
        user_id: customer.id,
        amount: amount,
        payment_date: DateTime.current.to_s,
        payment_id: parking_session_payment_id
      }).deliver_later
    end

    def set_payment_receipt_message(parking_session_payment_id)
      locales_key = "activerecord.models.message.templates.invoice_text"

      message_text = I18n.t(locales_key, {
        user_first_name: customer.first_name,
        parking_session_id: object.id,
        amount: amount,
        payment_details_date: formatted_datetime(DateTime.current),
        payment_id: parking_session_payment_id
      })
      message = customer.messages.create!(template: :invoice, text: message_text, to: customer)
      User::PushNotificationToken.send_message(customer, message)
    end
  end
end
