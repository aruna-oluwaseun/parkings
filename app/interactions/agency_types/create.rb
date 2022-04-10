module AgencyTypes
  # This class gives a place to put business logic related with creating agency type
  class Create < ApplicationInteraction
    include CreateWithObject

    string :name

    # @return [Hash]
    def execute
      simple_create(::AgencyType)
    end
  end
end
