##
# Model to handle parking citation tickets. This citation tickets are associated to parking violation
# ## Table's Columns
# - description => [string] It's not used, we instead use the description associated to {Parking::Rule parking rule} instance
# - violation_id => [bigint] Reference ID to {Parking::Violation Violation} instance
# - created_at => [datetime]
# - updated_at => [datetime]
class Parking::CitationTicket < ApplicationRecord
  belongs_to :violation
  has_many :comments, as: :subject
  has_many :parking_lots, through: :violations

  STATUSES = {
    unsettled: 0,
    settled: 1,
    canceled: 2,
    sent_to_court: 3
  }.freeze

  enum status: STATUSES

  has_paper_trail ignore: [:updated_at], versions: {
    scope: -> { order('id desc') },
    name: :logs
  }

  scope :by_parking_lot_ids, -> (parking_lot_ids) {
    joins(violation: { session: :parking_lot }).
      where('parking_sessions.parking_lot_id IN (?)', parking_lot_ids)
  }

  def vehicle
    violation.vehicle_rule&.vehicle || violation
  end

  # @return ActiveRecord::Relation of {Parking::CitationTicket citation ticket model}
  def self.with_role_condition(user)
    scope = all

    case user.role.name.to_sym
    when :super_admin
      scope
    when :town_manager
      scope.joins(violation: { ticket: { admin: :role } })
           .where(roles: { name: :town_manager })
           .where(admins: { id: user.id })
    when :parking_admin
      scope.joins(violation: { ticket: :admin })
           .where(admins: { id: user.id })
    when :manager
      scope.joins(violation: { ticket: { agency: :managers } })
           .where(admins: { id: user.id })
    when :officer
      scope.joins(violation: { ticket: { agency: :officers } })
           .where(admins: { id: user.id })
    else
      scope.none
    end
  end
end
