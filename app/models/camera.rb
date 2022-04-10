##
# Model to operate the system cameras, intended to be use by the {Admin admin model} on the dashboard project
# @see https://telsoft.atlassian.net/browse/PSAD-439 Camera Epic
# ## Table's Columns
# - stream => [string] URL to connect to the camera
# - login => [string] username account (if needed)
# - password => [string] password to authenticate (if needed)
# - name => [string] Name identifier
# - parking_lot_id => [bigint] ID reference to {ParkingLot parking lot model}
# - vmarkup => [json] it is a json configuration to calibrate the camera (check: PSAD-511)
# - other_information => [string] Extra data added just for information purposes
# - allowed => [boolean] Indicate if a non admin (super admin) can see the camera streaming
# - created_at => [datetime]
# - updated_at => [datetime]

class Camera < ApplicationRecord
  belongs_to :parking_lot
  attribute :stream, :uri
  attribute :password, :encrypted
  validates_uniqueness_of :number, scope: :parking_lot
  VMARKUP_KEYS = [:markup, :mvm, :ground].freeze
  store_accessor :vmarkup, *VMARKUP_KEYS
  validates :name, presence: true, length: { minimum: 3, maximum: 15 }

  enum status: { up: 0, down: 1 }
end
