module ParkingLots
  module ParkingPlan
    class Create < ApplicationInteraction

      interface :parking_plan_image, default: nil
      string :name, default: nil
      object :object, class: ParkingLot

      validates :name,
        presence: true

      def execute
        ActiveRecord::Base.transaction do
          transactional_create!(Image, file: { data: parking_plan_image }, meta_name: name, imageable: object)
          raise ActiveRecord::Rollback if errors.any?
        end
        self
      end
    end
  end
end
