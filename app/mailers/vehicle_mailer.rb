class VehicleMailer < ApplicationMailer
  %w(active create inactive rejected).each do |operation|
    define_method operation do |session|
      set_variables(session)
      mail(
        to: @email,
        subject: I18n.t("vehicle_mailer.#{operation}.subject")
      )
    end
  end

  private

  def set_variables(id)
    @vehicle = Vehicle::find(id)
    @user= User.find(@vehicle.user_id)
    @email= @user.email
  end
end
