module AgencyTypes
  # This class gives a place to put business logic related with removing agency type
  class Delete < ApplicationInteraction
    object :object, class: AgencyType

    # @return [Hash]
    def execute
      if object.can_deleted?
        object.destroy
      else
        errors.add(:agency_type, :cannot_be_deleted)
      end
    end
  end
end
