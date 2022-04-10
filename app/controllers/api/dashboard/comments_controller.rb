module Api
  module Dashboard
    class CommentsController < ApplicationController
      api :GET, '/api/dashboard/comments', 'Comment list of a Parking Violation Report or a Citation Ticket'
      header :Authorization, 'Auth token', required: true
      param :subject_type, [::Parking::Violation.name, ::Parking::CitationTicket.name], required: true
      param :subject_id, Integer, 'Violation Report or Citation Ticket id', required: true
      param :per_page, Integer, 'Items per page count, default is 10. Check response headers for total count (key: X-Total)', required: false
      param :page, Integer, 'Items page number', required: false

      def index
        authorize! ::Comment
        scope = paginate CommentsQuery.call(params.merge(user: current_user))
        respond_with scope, each_serializer: CommentSerializer
      end

      api :POST, '/api/dashboard/comments', 'Create comment'
      header :Authorization, 'Auth token', required: true

      param :comment, Hash, required: true do
        param :content, String, required: true
        param :subject_type, [::Parking::Violation.name, ::Parking::CitationTicket.name], required: true
        param :subject_id, Integer, 'Violation Report or Citation Ticket id', required: true
      end

      def create
        authorize! ::Comment
        payload = params.fetch(:comment, {}).merge(admin_id: current_user.id)
        result = Comments::Create.run(payload)
        respond_with result, serializer: CommentSerializer
      end

      api :PUT, '/api/dashboard/comments/:id', 'Update comment'
      header :Authorization, 'Auth token', required: true
      param :comment, Hash, required: true do
        param :content, String, required: true
      end

      def update
        comment = Comment.find(params[:id])
        authorize! comment
        payload = params.fetch(:comment, {}).merge(comment: comment)
        result = Comments::Update.run(payload)
        respond_with result.comment, serializer: CommentSerializer
      end

      api :DELETE, '/api/dashboard/comments/:id', 'Delete comment'
      param :id, String, 'Comment id', required: true
      header :Authorization, 'Auth token from users#sign_in', required: true

      def destroy
        comment = Comment.find(params[:id])
        authorize! comment
        comment.destroy
        respond_with status_code: 200
      end
    end
  end
end
