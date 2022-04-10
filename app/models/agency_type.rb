##
# Model to handle agency type data on the system
# ## Table's Columns
# - name => [string]
# - created_at => [datetime]
# - updated_at => [datetime]
#
# ## Associations:
# - AgencyTypes has a {Agency agency} associated to it

class AgencyType < ApplicationRecord
  has_one :agency, dependent: :restrict_with_error

  DEFAULT_NAMES = [
    'MEO (Meter Enforcement Officer)',
    'Town Police',
    'State Police'
  ]

  validates :name,
    presence: true,
    uniqueness: {
      case_sensitive: false,
      message: I18n.t('activerecord.errors.models.agency_type.attributes.name')
    }

  # @overload can_deleted?
  # This method checks if agency type can be deleted
  # We can not delete a agency type that already assigned to an agency
  # or it is a default type name (one of DEFAULT_NAMES)
  # @return [Boolean]
  def can_deleted?
    Agency.where(agency_type_id: id).empty? && !DEFAULT_NAMES.include?(name)
  end
end
