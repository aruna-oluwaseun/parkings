##
# Model to handle agencies data on the system
# ## Table's Columns
# - name => [string] Agency name
# - email => [string] Email to use to notify if an agency event happens
# - status => [integer] Agency state (active or inactive)
# - avatar => [string]  Agency Profile picture
# - phone => [string]  Agency phone number
# - agency_type_id => [bigint] Reference ID to a {AgencyType agency_type}
# - updated_at => [datetime]
# - created_at => [datetime]
#
# ## Associations:
# - Agencies has a {Location location} associated to it
# - Agencies technically can have severals {Admin town_managers} but we need only one, the reason is in case logic bussiness start needing several at the same time
# - Agencies technically can have severals {Admin officers} but we need only one, the reason is in case logic bussiness start needing several at the same time
# - Agencies have {Parking::Ticket parking tickets} associated to it
# - Agencies have {Parking::Rule parking rule} associated to it

class Agency < ApplicationRecord
  include ActiveStorageSupport::SupportForBase64

  has_many :rights, class_name: 'Admin::Right', as: :subject, dependent: :destroy
  has_many :admins, through: :rights
  has_many :managers, -> { joins(:role).where(roles: { name: :manager }, status: :active) }, class_name: 'Admin', through: :rights, source: :admin
  has_many :officers, -> { joins(:role).where(roles: { name: :officer }, status: :active) }, class_name: 'Admin', through: :rights, source: :admin
  has_one :location, as: :subject
  has_many :parking_tickets, class_name: 'Parking::Ticket', dependent: :destroy
  has_many :parking_lots
  belongs_to :agency_type, optional: true

  validates :email, presence: true
  validates_format_of :email, with: Devise.email_regexp, if: -> { email.present? }
  validates :phone, phony_plausible: true, if: -> { phone.present? }

  validates :name,
    presence: true,
    uniqueness: {
      case_sensitive: false,
      message: I18n.t('activerecord.errors.models.agency.attributes.name')
    }

  has_one_base64_attached :avatar
  validates :avatar, size: { less_than: 10.megabytes }

  enum status: { active: 0, inactive: 1 }

  accepts_nested_attributes_for :location

  has_paper_trail ignore: [:created_at, :updated_at], versions: {
    scope: -> { order('id desc') },
    name: :logs
  }

  # Simulate belongs_to association with {Admin Admin model}
  # @return first manager
  def manager
    managers.first
  end

  # It helps to handle the access that each roles has on the system to be able to interact with an agency
  # @return ActiveRecord::Relation of {Agency agency model}
  def self.with_role_condition(user)
    scope = all

    case user.role.name.to_sym
    when :parking_admin
      scope.none
    when :manager
      scope.joins(:managers).where(admins: { id: user.id })
    when :officer
      scope.joins(:officers).where(admins: { id: user.id })
    else
      scope
    end
  end

  # @overload can_deleted?
  # This method checks if the agency can be removed
  # @return[Boolean]
  def can_deleted?
    officers.empty? && ::Parking::Ticket
                        .joins(:agency)
                        .where(agency_id: id)
                        .where(status: Parking::Ticket.statuses[:opened])
                        .empty?
  end

  def avatar_thumbnail
    avatar.variant(resize: '200x200').processed
  rescue Errno::ENOENT # In case the image was deleted directly on the server
    avatar.purge # Remove association because it doesn't exist
    nil
  end
  
end
