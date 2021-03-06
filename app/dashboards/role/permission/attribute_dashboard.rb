require "administrate/base_dashboard"

class Role::Permission::AttributeDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    permission: Field::BelongsTo.with_options(class_name: 'Role::Permission'),
    id: Field::Number,
    name: Field::String,
    attr_read: Field::Boolean,
    attr_update: Field::Boolean,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :id,
    :name,
    :attr_read,
    :attr_update
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :permission,
    :id,
    :name,
    :attr_read,
    :attr_update,
    :created_at,
    :updated_at,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :permission,
    :name,
    :attr_read,
    :attr_update,
  ].freeze

  # Overwrite this method to customize how attr permissions are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(attr)
    attr.name
  end
end
