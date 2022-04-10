class UpdateAgencyTypeAndNotificationPermissions < ActiveRecord::Migration[5.2]
  def change
    RolesUpdateCommand.new.execute
  end
end
