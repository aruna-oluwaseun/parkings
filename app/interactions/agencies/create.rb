module Agencies
  class Create < Base
    attr_reader :agency

    string :email
    string :name
    string :status, default: 'active'
    string :phone, default: nil
    integer :manager_id
    integer :agency_type_id, default: nil
    array :officer_ids, default: [] do
      integer
    end
    interface :avatar, default: nil
    hash :location, strip: false

    validates :location, :email, :name, presence: true
    validate :validate_manager
    validate :validate_officers, if: -> { officer_ids&.any? }
    validate :validate_agency_type, if: -> { agency_type_id }

    set_callback :execute, :after, :notify_users, if: :valid?

    def execute
      ActiveRecord::Base.transaction do
        @agency = transactional_create!(Agency, agency_params)
        transactional_create!(Location, location_params.merge(subject: agency))
        parking_lots.update_all(agency_id: @agency.id)

        raise ActiveRecord::Rollback if errors.any?
      end
      self
    end

    private

    def agency_params
      super.merge(
        managers: [manager],
        officers: officers,
        agency_type: agency_type
      )
    end

    def officers
      @officers.present? ? @officers : []
    end

    def notify_users
      Admin.active.full_access.find_each do |admin|
        AdminMailer.subject_created(agency, admin).deliver_later
      end

      [manager, officers].flatten.each do |admin|
        AdminMailer.assigned_to_agency(agency.id, admin.id).deliver_later
      end

    end
  end
end
