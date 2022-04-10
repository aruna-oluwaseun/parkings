module AgencyTypes
  # This class gives a place to put business logic related with updating agency type
  class Update < ApplicationInteraction
    object :object, class: AgencyType

    string :name

    # @return [Hash]
    def execute
      object.update(filled_inputs)
    end
  end
end
