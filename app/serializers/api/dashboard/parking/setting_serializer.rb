module Api
  module Dashboard
    module Parking
      class SettingSerializer < ::ApplicationSerializer
        attributes :rate,
                   :incremental,
                   :parked,
                   :overtime,
                   :period,
                   :subject_id,
                   :subject_type
      end
    end
  end
end
