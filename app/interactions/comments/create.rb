module Comments
  class Create < Base
    include CreateWithObject
    attr_reader :comment

    string :content
    string :subject_type
    integer :subject_id
    integer :admin_id

    validates :content, :subject_type, :subject_id, :admin_id, presence: true

    # @return [Hash]
    def execute
      simple_create(Comment)
    end
  end
end
