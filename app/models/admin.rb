##
# Model To handle the administrators of the system (super admins, town managers, managers, officers and parking admins)
# ## Table's Columns
# - email => [string] Email use to address the user accounts
# - password => [string] Secret string to log in
# - reset_password_token => [string] Handle by {https://github.com/plataformatec/devise Devise}
# - reset_password_sent_at => [datetime] Handle by {https://github.com/plataformatec/devise Devise}
# - remember_created_at => [datetime] Handle by {https://github.com/plataformatec/devise Devise}
# - current_sign_in_at => [datetime] Handle by {https://github.com/plataformatec/devise Devise}
# - last_sign_in_at => [datetime] Handle by {https://github.com/plataformatec/devise Devise}
# - username => [string] String use to address the user accounts
# - phone => [string] Phone number to contact the administrator
# - avatar => [string] Profile picture
# - name => [string] Administrator full name
# - status => [integer] State of the account (active or inactive)
# - trackers => [Array] array of string to store all tracker ID used by a user
# - role_id => [bigint] ID associated to a system Role, more info on {Role Role model}
# - created_at => [datetime]
# - updated_at => [datetime]

class Admin < ApplicationRecord
  include AdminManagedUsers
  include TokenAuthorizable
  include ActiveStorageSupport::SupportForBase64

  devise :database_authenticatable, :recoverable, :rememberable, :validatable, password_length: 7..50
  with_options dependent: :destroy do |assoc|
    assoc.has_many :tokens, class_name: 'Admin::Token'
    assoc.has_many :rights, class_name: 'Admin::Right'
    assoc.has_many :comments
  end

  has_many :parking_lots, through: :rights, source: :subject, source_type: 'ParkingLot'
  has_many :disputes, dependent: :nullify
  has_many :messages, as: :author, dependent: :nullify
  has_many :parking_tickets, class_name: "Parking::Ticket", dependent: :nullify
  belongs_to :role

  Role::NAMES.each do |role|
    scope role, -> { joins(:role).where(roles: { name: role }) }
    delegate "#{role}?", to: :role
  end

  scope :full_access, -> { joins(:role).where(roles: { name: :super_admin }) }

  validates :username, presence: true, uniqueness: true, length: { minimum: 7, maximum: 20 }
  validates_format_of :username, with: /\A[a-zA-Z0-9]*\z/
  validates :phone, phony_plausible: true
  validates :status, :name, presence: true

  enum status: { active: 0, suspended: 1 }

  has_one_base64_attached :avatar

  attr_accessor :login

  # Function to override devise_mailer
  # @return AdminMailer mailer class
  def devise_mailer
    AdminMailer
  end

  # This is an internal method called every time Devise needs to send a notification/mail
  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end

  # @!method can_create_role?(role)
  #   Indicate if the admin instance can create a new admin with a certain role
  #   @param [String] role name
  #   @return Boolean
  # @!method can_read_role?(role)
  #   Indicate if the admin instance can read a new admin with a certain role
  #   @param [String] role name
  #   @return Boolean
  # @!method can_update_role?(role)
  #   Indicate if the admin instance can update a new admin with a certain role
  #   @param [String] role name
  #   @return Boolean
  # @!method can_delete_role?(role)
  #   Indicate if the admin instance can delete a new admin with a certain role
  #   @param [String] role name
  #   @return Boolean
  %w(create read update delete).each do |operation|
    define_method "can_#{operation}_role?" do |role|
      admin? || Access::Admin.new(self, role.name).send("#{operation}?")
    end
  end

  # Indicates if the admin instance is super admin, more info on: {Role Role Model}
  def admin?
    role.super_admin?
  end



  # @overload agency_manager?
  # It indicates if admin user is a manager
  # @return [Object]
  def agency_manager?
    manager? && Admin::Right.where(
      subject_type: 'Agency', admin_id: id
    ).any?
  end

  # @overload agency_officer?
  # It indicates if admin user is an officer
  # @return [Object]
  def agency_officer?
    officer? && Admin::Right.where(
      subject_type: 'Agency', admin_id: id
    ).any?
  end

  # Gets associated {ParkingLot Parking Lots} to the admin instance, mostly used when it's a parking admin or town manager
  # In case of super admin and system admin, they will see all parking lots on the database
  # @return ActiveRecord::Relation of {ParkingLot Parking Lot model}
  def available_parking_lots
    if super_admin?
      ParkingLot.all
    else
      parking_lots
    end
  end

  # Gets associated {Agencies} to the admin instance, mostly used when it's a parking admin or town manager
  # In case of super admin and system admin, they will see all agencies on the database
  # @return ActiveRecord::Relation of {Agency model}
  def available_agencies
    if super_admin? || town_manager?
      Agency.all
    elsif manager?
      agency_ids = ::Admin::Right.where(
                    subject_type: 'Agency', admin_id: id
                  ).select(:subject_id)
      Agency.where(id: agency_ids)
    else
      []
    end
  end

  # Gets associated {ParkingLot Parking Lots} to the admin instance, mostly used when it's a parking admin or town manager
  # In case of super admin and system admin, town manager they will see all parking lots on the database
  # Use this method only for revenue detailed report pages or statistics tiles report
  # @return ActiveRecord::Relation of {ParkingLot Parking Lot model}
  def revenue_report_parking_lots
    scope = ParkingLot.all

    case role.name.to_sym
    when :super_admin
      scope
    when :system_admin
      scope
    when :town_manager
      scope
    when :parking_admin
      parking_lots
    else
      scope.none
    end
  end
  
  # Gets admin's managed users in the system.
  # @return ActiveRecord of { Admin model }
  def managed_users
    return [] unless defined?("managed_by_#{role.name}")
    send("managed_by_#{role.name}")
  end

  # Overwriten function from {https://github.com/plataformatec/devise/wiki/How-To:-Allow-users-to-sign-in-using-their-username-or-email-address#overwrite-devises-find_for_database_authentication-method-in-user-model Devise}
  # to authenticate user with our own behavior
  # @return ActiveRecord::Relation of {Admin Admin model}
  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions.to_h).where(["lower(username) = :value OR lower(email) = :value", { value: login.downcase }]).first
    elsif conditions.has_key?(:username) || conditions.has_key?(:email)
      where(conditions.to_h).first
    end
  end

  # This functions checks if the admin role is a predefined role.
  # @return [boolean]
  def with_predefined_role?
    return false unless role.name.present?
    ::Role::NAMES.include?(role.name.underscore.to_sym)
  end

  # This functions checks if the current admin has create permissions.
  # @return [boolean]
  def can_create?(model)
    permission(model)&.record_create? || false
  end

  # This functions checks if the current admin has read permissions.
  # @return [boolean]
  def can_read?(model)
    permission(model)&.record_read? || false
  end

  # This functions checks if the current admin has uodate permissions.
  # @return [boolean]
  def can_update?(model)
    permission(model)&.record_update? || false
  end

  # This functions checks if the current admin has delete permissions.
  # @return [boolean]
  def can_delete?(model)
    permission(model)&.record_delete? || false
  end

  # This method search the permissions for a certain model in the current admin role.
  # @return [boolean]
  def permission(model)
    role.permissions.find_by_name(model)
  end
end
