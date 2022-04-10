module Users
  class Base < ::ApplicationInteraction
    object :user, class: User
    object :current_user, class: Admin

    validates :status, inclusion: { in: Admin.statuses.keys, message: I18n.t('activerecord.errors.models.user.attributes.status.invalid') }, if: :status

    def to_model
      user.reload
    end

    private

    def user_params
      data = inputs.slice(:is_dev, :status)
      data[:is_dev] = user.is_dev if data[:is_dev].nil?
      data[:status] = user.status if data[:status].nil?
      data
    end

    # This method checks if the current role is allowed to flag a user as a dev user.
    # @return [Hash]
    def validate_dev
      errors.add(:dev, :unauthorized) unless current_user.admin? || inputs[:is_dev].nil?
    end
  end
end
