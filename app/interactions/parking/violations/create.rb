module Parking::Violations
  class Create < Base
    include CreateWithObject
    attr_reader :parking_violation

    string :plate_number
    integer :agency_id
    integer :officer_id
    hash :parking_lot, strip: false
    hash :parking_rule, strip: false
    hash :ticket, strip: false, default: {}

    validates :plate_number, presence: true
    validate :validate_officer

    def execute
      Parking::Violation.transaction do
        search_parking_lot
        search_rule
        search_agency
        unless errors.any?
          create_with_block { transactional_create!(Parking::Violation, plate_number: plate_number, rule: @parking_rule) }
          create_ticket
          save_images(object)
        end
        raise ActiveRecord::Rollback if errors.any?
        self
      end
    end

    private

    def search_parking_lot
      @parking_lot = ParkingLot.find_by(id: parking_lot_params[:id])
      errors.add(:parking_lot, :not_found) unless @parking_lot
    end

    def search_rule
      name = parking_rule_params[:name]
      @parking_rule = @parking_lot.rules.where(name: Parking::Rule.names[name]).first
      errors.add(:parking_rule, :not_found) unless @parking_rule
    end

    def search_agency
      @agency = Agency.find_by(id: agency_id)
      errors.add(:agency, :not_found) unless @agency
    end

    def create_ticket
      officer = Admin.find_by(id: officer_id)
      if officer
        transactional_create!(Parking::Ticket, violation: object, agency: @agency, admin: officer)
      else
        errors.add(:officer, :not_found)
      end
    end
  end
end
