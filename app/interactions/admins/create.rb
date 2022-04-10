module Admins
  class Create < Base
    attr_reader :password, :user, :user_role, :user, :parking_lots, :agency

    string :email
    string :status
    string :username
    string :phone, default: nil # Optional
    string :name
    string :role_type
    array :parking_lot_ids, default: []
    string :agency_id, default: nil
    interface :avatar # can be File or String

    set_callback :execute, :before, :set_user_role
    set_callback :execute, :before, :set_parking_lots
    set_callback :execute, :before, :set_agency

    def execute
      ActiveRecord::Base.transaction do
        begin
          if new_user.save
            assign_user_to_parking_lots
            assign_user_to_agencies

            send_mail_to_creator
            send_mail_to_new_user
          else
            errors.merge!(new_user.errors)
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

    def new_user
      role = Role.find_by_name(user_role)
      @user ||= begin
        @password = SecureRandom.hex(5)
        Admin.new(user_params.merge(password: password, role: role))
      end
    end

    def send_mail_to_creator
      AdminMailer.user_created(user, current_user).deliver_later
    end

    def send_mail_to_new_user
      AdminMailer.welcome_letter(user, password).deliver_later
    end
  end
end
