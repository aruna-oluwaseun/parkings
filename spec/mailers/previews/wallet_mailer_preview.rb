class WalletMailerPreview < ActionMailer::Preview
  # Accessible from http://localhost:3000/rails/mailers/wallet_mailer/filled
  def filled
    WalletMailer.filled(user, 35)
  end

  # Accessible from http://localhost:3000/rails/mailers/wallet_mailer/almost_empty
  def almost_empty
    WalletMailer.almost_empty(user)
  end

  private

  def user
    User.new(email: 'test@test.com', first_name: 'Timothy')
  end
end
