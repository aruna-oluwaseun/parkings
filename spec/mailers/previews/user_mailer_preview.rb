class UserMailerPreview < ActionMailer::Preview

  # Accessible from http://localhost:3000/rails/mailers/user_mailer/reset_password_instructions
  def reset_password_instructions
    user = User.new(first_name: 'John', email: 'test@test.com')
    UserMailer.reset_password_instructions(user, '12345678', {})
  end

  # Accessible from http://localhost:3000/rails/mailers/user_mailer/confirmation_instructions
  def confirmation_instructions
    user = User.new(email: 'test@test.com', first_name: 'John')
    UserMailer.confirmation_instructions(user, '12345678', {})
  end

  # Accessible from http://localhost:3000/rails/mailers/user_mailer/password_change
  def password_change
    user = User.new(first_name: 'John')
    UserMailer.password_change(user, {})
  end

  # Accessible from http://localhost:3000/rails/mailers/user_mailer/payment_receipt
  def payment_receipt
    UserMailer.payment_receipt({
      user_id: User.last.id,
      session_id: ParkingSession.last.id,
      amount: 250,
      reference_id: 'PAYMNT-GTWAY-REF-ID',
      payment_date: DateTime.current.to_s,
      card_last_four_digits: '3232',
      card_network: 'MASTERCARD',
      payment_id: '3232',
      payment_method: 'PAY_WITH_CC'
    })
  end
end
