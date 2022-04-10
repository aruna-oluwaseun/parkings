module Comments
  class Update < Base
    object :comment
    string :content, default: nil

    def execute
      transactional_update!(comment, { content: content })
    end
  end
end
