module Api
  module Dashboard
    module Parking
      class DetailedSlotSerializer < SlotSerializer
        attributes :created_at, :updated_at, :updated_by

        has_one :updated_by, serializer: ::Api::Dashboard::UserSerializer

        def created_at
          utc(object.created_at)
        end

        def updated_at
          utc(object.updated_at)
        end

        def updated_by
          if object.logs.present?
            admin = Admin.find_by(id: object.logs.first.whodunnit)
          end
        end
      end
    end
  end
end
