class AddMinutesExtendedUserNotifications < ActiveRecord::Migration[5.2]
  def change
    add_column :user_notifications, :minutes_extended, :integer
  end
end
