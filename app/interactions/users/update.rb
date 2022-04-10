module Users
  class Update < Base
    string :status, default: nil
    boolean :is_dev, default: nil

    validate :validate_dev

    def execute
      User.transaction do
        transactional_update!(user, user_params)
      end
    end
  end
end
