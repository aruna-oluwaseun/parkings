module Roles
  class Delete < Base

    object :object, class: Role
    validate :validate_predefined_role
    validate :validate_users_with_role

    # @return [Hash]
    def execute
      object.destroy
    end

    private

    # This method checks if the current role it's a predefined role
    # @return [Hash]
    def validate_predefined_role
      errors.add(:role, :predefined_role) if object.name?
    end

    # This method checks that the current role is not assigned to any user.
    # @return [Hash]
    def validate_users_with_role
      errors.add(:role, :users_with_role) if object.admins.any? && object.name.nil?
    end
  end
end
