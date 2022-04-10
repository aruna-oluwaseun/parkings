#
# Model to handle Vehicles, this vehicle can be created by the {User user} itself
# or can be created by the AI by triggering one's of the files at app/interactions/parking_sessions/
# ## Table's Columns
# - plate_number => [string] Indicates the plate number type by the User or the one identified by the AI
# - vehicle_type => [string] Indicates the type of the vehicle
# - color => [string]  Indicates the color of the vehicle
# - model => [string] Indicates the model of the vehicle
# - user_id => [bigint] Reference ID to the {User user} owner
# - status => [integer] Indicate if the user 'deleted' the vehicle from the system, because we actually don't remove it
# - created_at => [datetime]
# - updated_at => [datetime]
class Vehicle < ApplicationRecord
  include ActiveStorageSupport::SupportForBase64

  has_many :parking_sessions, dependent: :nullify

  with_options dependent: :destroy do |assoc|
    assoc.has_many :rules, class_name: 'Parking::VehicleRule'
  end

  with_options optional: :true do |assoc|
    assoc.belongs_to :user
    assoc.belongs_to :manufacturer
  end

  has_many_base64_attached :images
  has_one_base64_attached :registration_card

  validates_uniqueness_of :plate_number, allow_nil: true
  enum status: { pending: 0, deleted: 4, active: 1, inactive: 2, rejected: 3 }

  before_validation do
    new_plate_number = plate_number&.downcase
    if new_plate_number == 'null'
      self.plate_number = nil
    else
      self.plate_number = new_plate_number&.remove_non_alphanumeric
    end
  end

  def recognized?
    plate_number.present?
  end

  # @overload can_deleted?
  # This method checks if the vehicle can be removed from the database
  # A vehicle record can be removed from the database only if it has no parking sessions in the system or
  # if vehicle is in pending or in rejected status
  # @return[Boolean]
  def can_deleted?
    parking_sessions.empty? || (pending? || rejected?)
  end

  # @overload editable?
  # This method checks if the vehicle can be updated
  # A vehicle record can be updated only if it has no parking sessions in the system or
  # if vehicle is in pending or in rejected status
  # @return[Boolean]
  def editable?
    can_deleted?
  end
  
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
