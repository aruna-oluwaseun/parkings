##
# Model to handle location data form any model in our system
# Our model using this association are: {Agency Agency model} and {ParkingLot Parking lot model}
# ## Table's Columns
# - zip => [string]
# - building => [string]
# - street => [string]
# - city => [string]
# - country => [string]
# - ltd => [float]
# - lng => [float]
# - subject_type => [string]
# - subject_id => [bigint]
# - full_address => [string] Attribute constructed before saving
# - state => [string]
# - created_at => [datetime]
# - updated_at => [datetime]
class Location < ApplicationRecord
  belongs_to :subject, polymorphic: true

  validates :lng, :ltd, :city, :state, :street, :country, presence: true

  before_validation do
    if building.blank? && zip.blank?
      location_full_address = "#{street}, #{city}, #{country}"
    elsif !building.blank? && zip.blank?
      location_full_address = "#{street} #{building}, #{city}, #{country}"
    elsif building.blank? && !zip.blank?
      location_full_address = "#{street}, #{city}, #{country}, #{zip}"
    elsif !building.blank? && !zip.blank?
      location_full_address = "#{street} #{building}, #{city}, #{country}, #{zip}"
    end

    self.full_address = location_full_address
  end
end
