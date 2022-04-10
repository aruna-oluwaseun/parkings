module Agencies
  # This class gives a place to put business logic related with removing agency
  class Delete < ApplicationInteraction
    object :agency, class: Agency

    # @return [Hash]
    def execute
      if agency.can_deleted?
        agency.destroy
      else
        errors.add(:agency, :cannot_be_deleted)
      end
    end
  end
end
