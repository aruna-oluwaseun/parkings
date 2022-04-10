class PaymentMailer < ApplicationMailer
  def payment_successful(session, payment)
    user = session.vehicle.user
    @first_name = user.first_name
    @session_payment_amount = payment.amount
    @plate_number = session.vehicle.plate_number
    @wallet_amount = user.wallet.amount
    @email = user.email
    mail to: @email
  end

  def payment_failure(session)
    user = session.vehicle.user
    @first_name = user.first_name
    @plate_number = session.vehicle.plate_number
    @email = user.email
    mail to: @email
  end
end
