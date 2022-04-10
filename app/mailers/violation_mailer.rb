class ViolationMailer < ApplicationMailer
  def commited(email, violation)
    @email = email
    @violation = violation
    @violation_url = "#{ENV['DASHBOARD_DOMAIN']}/dashboard/violations/#{@violation.id}"
    mail to: email
  end

  def canceled(user, violation)
    @first_name = user.first_name
    @email = user.email
    @violation_id = violation.id
    @plate_number = violation.session.vehicle.plate_number
    mail to: @email
  end
end
