class AddReferencesToUserNotifications < ActiveRecord::Migration[5.2]
  def change
    add_reference :user_notifications, :payment, foreign_key: true
    add_reference :user_notifications, :wallet_recharge_payment, foreign_key: true
    add_reference :user_notifications, :violation, foreign_key: { to_table: :parking_violations }
  end
end
