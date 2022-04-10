module Api
  module Dashboard
    class CommentSerializer < ::ApplicationSerializer
      attributes :id, :content, :created_at, :updated_at, :subject_type, :subject, :user

      def subject
        object.subject
      end

      def user
        user = object.admin

        {
          id: user.id,
          name: user.name,
          image: user.avatar.attached? ? url_for(user.avatar) : nil
        }
      end
    end
  end
end
