module Comments
  class Base < ::ApplicationInteraction

    private

    def comment_params
      data = inputs.slice(:content, :subject_type, :subject_id, :admin_id)
    end
  end
end
