module Admins
  class SignIn < ::ApplicationInteraction
    attr_reader :admin, :token, :email

    ALLOWED_REQUESTER_TYPES = %w(dashboard meo)
    ALLOWED_ROLES = %w(super_admin manager officer town_manager)

    string :username
    string :password
    string :requester_type

    validate do
      unless requester_type.in?(ALLOWED_REQUESTER_TYPES)
        errors.add(:base, :invalid_requester_type)
        throw(:abort)
      end
      unless @admin = Admin.find_by(username: username.downcase) || Admin.find_by(email: username)
        if username.to_s.include?('@')
          errors.add(:username, :invalid_email)
        else
          errors.add(:username, :invalid_username)
        end
        throw(:abort)
      end
      unless @admin.valid_password?(password)
        errors.add(:password, :invalid)
        throw(:abort)
      end
      unless @admin.active?
        errors.add(:base, :account_not_active)
        throw(:abort)
      end
      if (ALLOWED_ROLES.exclude? @admin.role.name ) && (requester_type == 'meo')
        errors.add(:base, :wrong_access)
        throw(:abort)
      end
    end

    def execute
      @token = Authorizer.generate_token(admin)
      self
    end

    def to_model
      { token: token }
    end
  end
end
