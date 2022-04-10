class WalletMailer < ApplicationMailer
  def filled(user, amount)
    @user = user
    @amount = amount
    mail to: @user.email, subject: 'Wallet filled successfully'
  end

  def almost_empty(user)
    @user = user
    mail to: @user.email, subject: 'Wallet almost empty'
  end
end
