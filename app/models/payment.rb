##
# Model to handle payments for a parking session (a {ParkingSession parking session} can have multiple payments)
# ## Table's Columns
# - amount => [decimal] Amount in cent paid by the user
# - parking_session_id => [integer] Reference ID to a {ParkingSession parking session}
# - status => [integer] Indicates if the status was succeful or failed
# - payment_method => [string] How the user paid using wallet or cash via ksk
# - created_at => [datetime]
# - updated_at => [datetime]
class Payment < ApplicationRecord
  DEFAULT_AMOUNT = Money.new(0, 'USD')
  belongs_to :parking_session
  with_options  through: :parking_session do |assoc|
    assoc.has_one :parking_lot
    assoc.has_one :user
    assoc.has_one :vehicle
  end

  enum payment_method: [:cash, :credit_card, :free_pay, :wallet] # Free payment it should happen if the parking lot hourly rate is 0 (It's not implement yet)

  enum status: {
    failed: 0,
    success: 1,
    pending: 2
  }

  def amount_to_dollar
    Money.new(amount, 'USD')
  end

  # It helps to handle the access that each roles has on the system
  # to be able to interact with a dispute
  # @return ActiveRecord::Relation of {Dispute dispute model}
  def self.with_role_condition(admin)
    scope = all
    #If it is a manually created role, we will use the permissions from the Role::Permission model
    return scope unless admin.with_predefined_role?
    case admin.role.name.to_sym
    when :super_admin, :town_manager
      scope
    else
      scope.none
    end
  end
end
