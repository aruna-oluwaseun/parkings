module Api
  module Dashboard
    module Parking
      class SessionLogSerializer < ::ApplicationSerializer
        attributes :created_at, :changeset, :comment
      end
    end
  end
end
