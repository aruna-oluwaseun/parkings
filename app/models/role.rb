##
# Model for permission control usages, take a look at Access::Model class, There is bunch of examples of permission control usages
# ## Table's Columns
# - display_name => [string] How we identify the name on the system (for all roles, can be edited)
# - name => [string] How we identify the name on the system (for predefined roles, can't be edited)
# - full => [boolean] if it has full access to all the system features
# - parent_id => [integer] Reference to this same model
# - created_at => [datetime]
# - updated_at => [datetime]
# @see this lib/roles_seed_command.rb for current hierarchy on the system

class Role < ApplicationRecord
  has_many :admins, dependent: :nullify
  has_many :permissions, inverse_of: :role, dependent: :destroy

  with_options class_name: 'Role' do |assoc|
    assoc.has_many :children, foreign_key: :parent_id, dependent: :nullify
    assoc.belongs_to :parent, optional: true
  end

  NAMES = [:super_admin, :town_manager, :parking_admin, :manager, :officer].freeze

  PERMITTED_CREATABLE_ROLES = {
    super_admin: NAMES,
    town_manager: [:town_manager, :parking_admin, :manager, :officer],
    parking_admin: [],
    manager: [:manager, :officer],
    officer: []
  }.freeze

  validates :name, uniqueness: true, inclusion: { in: NAMES.map(&:to_s) }, allow_nil: true # Only for predefined roles.
  validates :display_name, presence: true, uniqueness: true, exclusion: { in: NAMES.map(&:to_s) } # For all roles. Also unique index is defined in db

  NAMES.each do |name|
    define_method "#{name}?" do
      return false if self.name.nil?
      self.name.to_sym == name
    end
  end
end
