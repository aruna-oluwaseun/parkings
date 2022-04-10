module Agencies
  class Update < Base
    attr_reader :agency_location

    object :agency, class: Agency
    string :email, default: nil
    string :name, default: nil
    string :status, default: 'active'
    string :phone, default: nil
    integer :manager_id, default: nil
    integer :agency_type_id, default: nil
    array :officer_ids, default: [] do
      integer
    end
    interface :avatar, default: nil
    hash :location, strip: false, default: {}

    validate :validate_manager, if: :manager_id
    validate :validate_officers, if: -> { officer_ids&.any? }
    validate :validate_agency_type, if: -> { agency_type_id }

    set_callback :execute, :before, :set_previous_admins
    set_callback :execute, :after, :notify_users, if: :valid?

    def execute
      ActiveRecord::Base.transaction do
        transactional_update!(agency, agency_params)
        transactional_update!(agency.location, location_params)
        agency.parking_lots = parking_lots

        raise ActiveRecord::Rollback if errors.any?
      end
      self
    end

    private

    def notify_users
      agency.reload

      Admin.active.full_access.find_each do |admin|
        AdminMailer.subject_updated(agency, admin).deliver_later
      end

      new_manager = agency.manager
      new_officers = agency.officers

      if @previous_manager != new_manager && [@previous_manager, new_manager].all?(&:present?)
        AdminMailer.assigned_to_agency(agency.id, new_manager.id).deliver_later
        AdminMailer.unassigned_from_agency(agency.id, @previous_manager.id).deliver_later
      end

      if Set.new(@previous_officers) != Set.new(new_officers)
        (@previous_officers - new_officers).each do |admin|
          remove_from_agency(agency, admin)
          AdminMailer.unassigned_from_agency(agency.id, admin.id).deliver_later
        end
        (new_officers - @previous_officers).each do |admin|
          AdminMailer.assigned_to_agency(agency.id, admin.id).deliver_later
        end
      end
    end

    def set_previous_admins
      @previous_officers = agency.officers.to_a
      @previous_manager = agency.manager
    end

    def agency_params
      prms = super
      prms[:managers] = [manager] if manager
      prms[:officers] = officers&.any? ? officers : []
      prms[:agency_type] = agency_type if agency_type
      prms
    end

    def remove_from_agency(agency, admin)
      ::Parking::Ticket.where(admin_id: admin.id, agency_id: agency.id).update_all(admin_id: nil)
    end
  end
end
