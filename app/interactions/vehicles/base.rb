
module Vehicles
  class Base < ApplicationInteraction
    # @overload validates_registration_card
    # This method checks that vehicle registration card image file size is less than 10 megabytes
    # @return[Hash]
    def validates_registration_card
      errors.add(:registration_card, :invalid_file_size) if registration_card && registration_card.size > 10.megabytes
    end
  end
end
