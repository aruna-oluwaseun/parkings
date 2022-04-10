##
# Model to handle violations created by the system,
# where an {Admin officer} will be in charge of issuing a ticket to the car.
# This model provide logs (with Papertrail) to trace the actions that occur on the parking ticket instance
# ## Table's Columns
# - admin_id => [bigint] Reference ID to an {Admin admin} instance
# - agency_id => [bigint] Reference ID to an {Agency agency} instance
# - status => [integer] Can be 3 statuses opened, resolved or issued
# - violation_id => [bigint] Reference to the Violation occurred
# - citation_ticket_id => [bigint] Reference ID to {Parking::CitationTicket Citation Ticket} instance
# - photo_resolution => [string] Photo that an officer might upload
# - created_at => [datetime]
# - updated_at => [datetime]
class Parking::Ticket < ApplicationRecord
  include ActiveStorageSupport::SupportForBase64

  STATUSES = {
    opened: 0,
    rejected: 1,
    approved: 2,
    closed: 3
  }.freeze

  enum status: STATUSES

  belongs_to :violation
  belongs_to :admin, optional: true
  belongs_to :agency, optional: true
  has_many :parking_lots, through: :violations

  has_paper_trail on: [:update], only: [:admin_id, :status], versions: {
    scope: -> { order("id desc") },
    name: :logs
  }
  paper_trail.on_create

  has_one_base64_attached :photo_resolution

  scope :by_parking_lot_ids, ->(parking_lot_ids) {
    joins(violation: { session: :parking_lot }).
      where('parking_sessions.parking_lot_id IN (?)', parking_lot_ids)
  }

  # @return ActiveRecord::Relation of {Parking::Ticket parking ticket model}
  def self.with_role_condition(user)
    scope = all

    #If it is a manually created role, we will use the permissions from the Role::Permission model
    return scope unless user.with_predefined_role?

    case user.role.name.to_sym
    when :town_manager
      scope.none
    when :parking_admin
      scope.none
    when :manager
      scope.joins(agency: :managers).where(admins: { id: user.id })
    when :officer
      scope.where(admin_id: user.id)
    else
      scope
    end
  end
end
