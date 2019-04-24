class Api::Comments::CommentsController < ApplicationController
  before_action :find_parent_comment

  def index
    @comments = @parent_comment.comments
    render 'api/comments/index', status: 200
  end

  def create
    @comment = @parent_comment.comments.create(comment_params)
    if @comment.save
      render 'api/comments/show', status: 201
    else
      render json: { errors: @comment.errors.full_messages }, status: 422
    end
  end

  private
  def comment_params
    params.require(:comment).permit(:body)
  end

  def find_parent_comment
    @parent_comment = Comment.find(params[:comment_id])
  rescue ActiveRecord::RecordNotFound
    render json: { errors: "Not Found" }, status: 404
  end
end