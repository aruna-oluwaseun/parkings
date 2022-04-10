module DropdownFields
  module Dashboard
    module AdminsByRole
      class ParkingAdmin < ::DropdownFields::Base

        def execute
          Admin.joins(:role).where(status: :active, roles: { name: 'parking_admin' }).map { |admin| { id: admin.id, username: admin.username } }
        end

        def value_attr
          :id
        end

        def label_attr
          :username
        end

      end
    end
  end
end
