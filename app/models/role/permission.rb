#
# Model to handle CRUD permissions between system Models
# ## Table's Columns
# - role_id => [integer] Reference ID to a {Role role} mode
# - name => [string] Identify permission by name
# - record_create => [boolean] Indicate if the role can **create** the model
# - record_read => [boolean] Indicate if the role can **read** the model
# - record_update => [boolean] Indicate if the role can **update** the model
# - record_delete => [boolean] Indicate if the role can **delete** the model
# - created_at => [datetime]
# - updated_at => [datetime]
# @note An example can be seed at {Admin admin model}
class Role::Permission < ApplicationRecord
  belongs_to :role, touch: true
  has_many :attrs, class_name: 'Attribute', inverse_of: :permission, dependent: :destroy

  # Permissions of the application
  # Add more models only if its require by application SRS
  # If you think that you need it ask PR to update SRS or review app.
  # May be some of models related or duplicated as it was with
  # Parking::Violation <- Parking::CitationTicket and Message <- Comment
  PERMISSIONS_AVAILABLE = %w(
    Role
    Admin
    User
    Vehicle
    ParkingLot
    Agency
    AgencyType
    Payment
    Dispute
    Parking::Violation
    Message
    Camera
    Report
    User::Notification
    Parking::CitationTicket
  ).freeze

  validates :name, inclusion: { in: PERMISSIONS_AVAILABLE }, uniqueness: { scope: [:role_id] } # table has cluster index on these 2 columns

  # This methods returns available permissable entities with
  # it's equivalent frontend label
  # @return [Array]
  def self.permission_available
    PERMISSIONS_AVAILABLE.map do |entity|
      {
        label: I18n.t("permission.permission_list.attributes.#{entity.underscore}"),
        name: entity
      }
    end
  end

  # This method get the attributes of each permissions.
  # @return [hash]
  def self.permissions_with_attributes
    permissions = []
    PERMISSIONS_AVAILABLE.each do |permission|
      admin_roles = Role::NAMES.map { |role| role.to_s.camelcase }
      permission_model = if permission.in?(admin_roles)
                          Admin
                         else
                           permission.singularize.classify.constantize rescue "Parking::#{permission}".singularize.classify.constantize
                         end
      column_names = permission_model.column_names
      column_names = (column_names + extra_permissions(permission)).uniq
      permissions.push({ name: permission, attrs: column_names })
    end
    permissions
  end

  # This method is to get specific attributes of certain models.
  # @return [hash]
  def self.extra_permissions(permission)
    case permission
    when 'Agency'
      %w(manager_id town_manager_id officer_ids)
    when 'ParkingLot'
      %w(parking_admin_id town_manager_id)
    when 'Role'
      %w(permissions)
    else
      []
    end
  end
end
