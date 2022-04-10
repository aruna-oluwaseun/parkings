module Parking::Rules
  class UpdateMultiple < ApplicationInteraction
    integer :lot_id
    integer :agency_id, default: nil
    array :rules

    def execute
      ActiveRecord::Base.transaction do
        rules.each do |rule|
          result = ::Parking::Rules::Update.run(rule.merge(lot_id: lot_id))

          result.errors.each do |field, error|
            errors.add(field, error)
          end
        end

        if agency_id.present?
          lot = ParkingLot.find(lot_id)
          transactional_update!(lot, {agency_id: agency_id})
        end

        if errors.any?
          raise ActiveRecord::Rollback
        end
      end
    end
  end
end
