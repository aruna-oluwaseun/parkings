class Ai::ErrorReport < ApplicationRecord
  ERROR_TYPES = {
    lpn_unrecognized: 0,
    car_entrance_unrecognized: 1,
    park_on_occupied_space: 2,
    duplicated_session: 3,
    car_leaving_slot_unrecognized: 4,
    lpn_or_img_not_present: 5,
    session_not_parked: 6,
    camera_down: 7
  }.freeze

  belongs_to :parking_session, optional: true

  enum error_type: ERROR_TYPES

end
