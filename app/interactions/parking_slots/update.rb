module ParkingSlots
  class Update < Base
    attr_reader :parking_slot

    object :parking_slot, class: ParkingSlot
    object :role
    string :name
    boolean :archived, default: false
    validate :validate_editable_title

    # @return [Hash]
    def execute
      ActiveRecord::Base.transaction do
        transactional_update!(parking_slot, parking_slot_params)
      end
      self
    end
  end
end
