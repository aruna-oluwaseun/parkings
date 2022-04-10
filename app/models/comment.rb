##
# Model to store Comments in Violations Report and Citation Ticket sections.
# ## Table's Columns
# - content => [text] Content of the published comment
# - subject_id => [bigint] Reference ID to a Parking::Violation or Parking::Ticket
# - admin_id => [bigint] Reference ID to a Admin
# - created_at => [datetime]
# - updated_at => [datetime]
class Comment < ApplicationRecord
  belongs_to :subject, polymorphic: true
  belongs_to :admin

  has_paper_trail(
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
      record_parent: subject_type,
      record_model: 'Comment',
      record_id: subject_id
    }
  end
end
