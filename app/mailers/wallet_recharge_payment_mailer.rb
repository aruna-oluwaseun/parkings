class WalletRechargePaymentMailer < ApplicationMailer
  def wallet_filled(user, wallet_recharge_payment)
    @first_name = user.first_name
    @wallet_recharge_payment_amount = wallet_recharge_payment.amount
    @email = user.email
    mail to: @email
  end

  def wallet_almost_empty(user)
    @first_name = user.first_name
    @email = user.email
    mail to: @email
  end
end
