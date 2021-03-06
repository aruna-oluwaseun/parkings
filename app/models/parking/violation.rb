##
# Model to store violation generated by a {ParkingSession parking session}. This is created on violation_commited.rb
# ## Table's Columns
# - description => [string] It's not used, we instead use the description associated to {Parking::Rule parking rule} instance
# - rule_id => [bigint] Reference ID to a {Parking::Rule parking rule}
# - session_id => [bigint] Reference ID to a {ParkingSession parking session}
# - parking_vehicle_rules_id => [bigint] Reference ID to a {Parking::VehicleRule parking vehicle rule}
# - created_at => [datetime]
# - updated_at => [datetime]
class Parking::Violation < ApplicationRecord
  belongs_to :rule
  belongs_to :vehicle_rule, class_name: "Parking::VehicleRule", foreign_key: :parking_vehicle_rules_id, optional: true
  belongs_to :session, class_name: 'ParkingSession', optional: true
  has_one :citation_ticket, foreign_key: 'violation_id', class_name: 'Parking::CitationTicket'

  validates_uniqueness_of :plate_number, allow_nil: true

  with_options dependent: :destroy do |assoc|
    assoc.has_many :images, as: :imageable
    assoc.has_one :ticket
    assoc.has_many :comments, as: :subject
  end

  with_options allow_nil: true do |violation|
    violation.delegate :agency, to: :rule
    violation.delegate :officers, to: :agency
    violation.delegate :parking_lot, to: :session
    violation.delegate :vehicle, to: :session
  end

  has_paper_trail ignore: [:updated_at], versions: {
    scope: -> { order('id desc') },
    name: :logs
  }

  scope :by_parking_lot_ids, ->(parking_lot_ids) {
    select('parking_lots.id').
    joins(session: :parking_lot).
    where('parking_lots.id IN (?)', parking_lot_ids)
  }

  scope :opened, -> {
    joins(:citation_ticket).
    where('parking_citation_tickets.status = ?', Parking::CitationTicket::STATUSES[:unsettled])
  }

  scope :rejected, -> {
    joins(:citation_ticket).
    where('parking_citation_tickets.status = ?', Parking::CitationTicket::STATUSES[:rejected])
  }

  # @return ActiveRecord::Relation of {Parking::Violation parking violation model}
  def self.with_role_condition(user)
    scope = all

    case user.role.name.to_sym
    when :town_manager
      scope.joins(rule: { lot: :town_managers }).where(admins: { id: user.id })
    when :parking_admin
      scope.joins(rule: { lot: :parking_admins }).where(admins: { id: user.id })
    when :manager
      scope.joins(ticket: { agency: :managers }).where(admins: { id: user.id })
    when :officer
      scope.joins(:ticket).where(parking_tickets: { admin_id: user.id })
    else
      scope
    end
  end
end
