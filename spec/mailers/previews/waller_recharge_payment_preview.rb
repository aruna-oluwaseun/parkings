class WalletRechargePaymentMailerPreview < ActionMailer::Preview

  # Accessible from http://localhost:3000/rails/mailers/wallet_recharge_payment_mailer/wallet_filled
  def wallet_filled
    user = User.new(email: 'test@test.com', first_name: 'John', wallet: Wallet.new(amount: 25.00))
    wallet_recharge_payment = WalletRechargePayment.new(amount: 25.00, user: user)
    WalletRechargePaymentMailer.wallet_filled(user, wallet_recharge_payment)
  end

  # Accessible from http://localhost:3000/rails/mailers/wallet_recharge_payment_mailer/wallet_almost_empty
  def wallet_almost_empty
    user = User.new(email: 'test@test.com', first_name: 'John')
    WalletRechargePaymentMailer.wallet_almost_empty(user)
  end
end
