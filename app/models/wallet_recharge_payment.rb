##
# Model to handle wallet recharge payments for user {User user} can have multiple payments)
# ## Table's Columns
# - amount => [decimal] Amount in cent recharged by the user
# - status => [integer] Indicates if the status was succeful or failed
# - payment_method => [string] How the user paid credit_card, cash or if it was a free
# - payment_gateway => [string] which payment gateway processed the payment
# - meta_data => [json] extra data returned by the payment gateway that might nbe useful to debug
# - created_at => [datetime]
# - updated_at => [datetime]
class WalletRechargePayment < ApplicationRecord
  belongs_to :user

  enum payment_method: [:cash, :credit_card, :free_pay] # Free payment it should happen if the parking lot hourly rate is 0 (It's not implement yet)

  enum status: {
    failed: 0,
    success: 1
  }
end
