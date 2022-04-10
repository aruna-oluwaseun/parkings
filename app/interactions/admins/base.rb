module Admins
  class Base < ::ApplicationInteraction
    ROLE_MAPPINGS = {
      super_admin: 'super_admin',
      town_manager: 'town_manager',
      agency_manager: 'manager',
      agency_officer: 'officer',
      parking_lot_manager: 'parking_admin'
    }.freeze

    object :current_user, class: Admin

    validates :status, inclusion: Admin.statuses.keys, if: -> { status.present? }

    def to_model
      user.reload
    end

    private

    def user_params
      data = inputs.slice(:email, :status, :username, :phone, :role_id, :name)
      data[:avatar] = { data: inputs[:avatar] } if inputs[:avatar].present?
      data
    end

    def set_parking_lots
      @parking_lots ||= ParkingLot.where(id: parking_lot_ids)
    end

    def set_agency
      @agency ||= Agency.find(agency_id) if agency_id.present?
    end

    def set_user_role
      @user_role ||= ROLE_MAPPINGS[role_type.to_sym]
    end

    def assign_user_to_parking_lots
      if user_role.present? && parking_lots.any? &&
         %i[town_manager parking_lot_manager].include?(role_type.to_sym)
        parking_lots.each do |parking_lot|
          if parking_lot.respond_to?(user_role.pluralize) &&
            (current_user.super_admin? || current_user.town_manager?)
            parking_lot.send(user_role.pluralize) << user
          end
        end
      end
    end

    def assign_user_to_agencies
      return unless %i[agency_manager agency_officer].include?(role_type.to_sym)
      errors.add(
        :base, "agency must be defined when creating #{role_type.titleize}"
      ) unless agency_id.present?

      if user_role.present? &&
         if agency.respond_to?(user_role.pluralize) &&
            (
              current_user.super_admin? ||
              current_user.town_manager? ||
              (current_user.manager? && agency.managers.include?(current_user))
            )
          agency.send(user_role.pluralize) << user
        end
      end
    end
  end
end
