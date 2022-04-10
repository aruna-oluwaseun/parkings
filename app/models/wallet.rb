##
# Model to store user balance.
# ## Table's Columns
# - user_id => [bigint] ID reference to the {User user modle}
# - amount => [decimal] Amount in cents available to user
# - created_at => [datetime]
# - updated_at => [datetime]
class Wallet < ApplicationRecord
  belongs_to :user
end
