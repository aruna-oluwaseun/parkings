class UserMailer < Devise::Mailer
  helper :application # gives access to all helpers defined within `application_helper`.
  include Devise::Controllers::UrlHelpers # Optional. eg. `confirmation_url`
  default template_path: 'user_mailer' # to make sure that your mailer uses the devise views

  def confirmation_instructions(record, token, opts={})
    opts[:subject] = "Account Confirmation Code: #{token}"
    @first_name = record.first_name
    super
  end

  def reset_password_instructions(record, token, *args)
    @reset_password_url = "https://#{ENV['APP_DOMAIN']}#{ENV['USERS_RESET_PASSWORD_PATH']}/#{token}"
    @first_name = record.first_name
    super
  end

  # user_id - current users id
  # session_id - ParkingSession ID
  # amount - Amount paid
  # payment_date - Date when the payment is made
  # payment_id - ParkingSession's Payment,
  #                  { ..., digital_wallet_attributes: { ..., encryptionhandler: ['EC_GOOGLE_PAY', 'EC_APPLE_PAY'] } }
  def payment_receipt(params)
    @user = User.find_by_id(params.dig(:user_id))
    @parking_session = ParkingSession.find_by_id(params.dig(:session_id))
    @amount = params.dig(:amount)
    @payment_date = params.dig(:payment_date)&.to_date
    @payment_id = params.dig(:payment_id)

    mail(
      from: "#{ENV['MAIL_SENDER_NAME']} <#{ENV['MAIL_FROM']}>",
      to: @user.email,
      subject: 'Park Smart Payment Confirmation'
    )
  end

  def password_change(*)
    super
  end
end
