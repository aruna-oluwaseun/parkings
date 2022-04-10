module Admins
  class Update < Base

    object :user, class: Admin
    string :email
    string :status
    string :username
    string :name
    string :password, default: nil
    string :phone, default: nil
    interface :avatar, default: nil # can be File or String
    boolean :delete_avatar, default: false

    string :role_type
    array :parking_lot_ids, default: []
    string :agency_id, default: nil

    set_callback :execute, :before, :set_user_role
    set_callback :execute, :before, :set_parking_lots
    set_callback :execute, :before, :set_agency

    validates :password, length: { minimum: 7, maximum: 50 }, if: :user_tries_to_change_password?

    attr_reader :user_role, :parking_lots, :agency

    def execute
      ActiveRecord::Base.transaction do
        begin
          user.avatar.purge if delete_avatar
          unassign_user_to_parking_lots
          unassign_user_agency

          role = Role.find_by_name(user_role)

          if user.update(user_params.merge!(role: role))
            assign_user_to_parking_lots
            assign_user_to_agencies
          else
            errors.merge!(user.errors)
          end
        rescue => e
          errors.add(:base, e.message)
          Raven.capture_exception(e)
          raise ActiveRecord::Rollback
        end
      end
      self
    end

    private

    def unassign_user_to_parking_lots
      return unless user.town_manager? || user.parking_admin?
      ::Admin::Right.where(subject_type: 'ParkingLot', admin_id: user.id).destroy_all
    end

    def unassign_user_agency
      if (user.agency_manager? || user.agency_officer?) && agency_id.present?
        ::Admin::Right.where(subject_type: 'Agency', admin_id: user.id).each do |current_agency|
          current_agency.destroy if current_agency.subject_id != agency_id
        end
      end
    end

    def user_params
      prms = super
      prms[:password] = password if user_tries_to_change_password?
      prms
    end

    def user_tries_to_change_password?
      password.present?
    end
  end
end
