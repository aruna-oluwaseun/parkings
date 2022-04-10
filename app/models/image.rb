##
# Model to handle multiple images that another model could have
class Image < ApplicationRecord
  include ActiveStorageSupport::SupportForBase64
  belongs_to :imageable, polymorphic: true
  has_one_base64_attached :file
  validates :file, presence: true

  has_paper_trail(
    ignore: [:updated_at],
    versions: {
      scope: -> { order('id desc') },
      name: :logs
    },
    meta: {
      meta_data: :meta_data
    }
  )

  # This method data is used in papertrail
  # to have records of deleted images
  def meta_data
    {
      record_parent: imageable_type,
      record_model: 'Image',
      record_id: imageable_id
    }
  end
end
