class Parking::History < ApplicationRecord
  belongs_to :user
  belongs_to :parking_session
end
