module Parking::Violations
  class Base < ApplicationInteraction
    attr_reader :officer
    array :images, default: []
    array :images_ids, default: []
    validate :validate_images_size, if: -> { images.any? }

    private

    def validate_officer
      if ticket[:officer_id]
        unless @officer = Admin.active.parking_admin.find_by(id: officer_id)
          errors.add(:officer, :not_found)
          throw(:abort)
        end
      end
    end

    def parking_lot_params
      parking_lot&.slice(:id)
    end

    def parking_rule_params
      data = parking_rule&.slice(:name)
      data[:agency_id] = inputs[:agency_id]
      data
    end

    def ticket_params
      data = ticket&.slice(:officer_id)
      data[:agency_id] = inputs[:agency_id]
      data
    end

    def validate_images_size
      images.each do |image|
        errors.add(:image, :invalid_size) if image.size > 1.5.megabytes
      end
    end

    def save_images(imageable)
      images.each do |file|
        transactional_create!(Image, file: { data: file }, imageable: imageable)
      end
    end

    def delete_images(object)
      return if images_ids.empty?

      object.images.where(id: images_ids).destroy_all
    end
  end
end
