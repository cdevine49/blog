class Api::CommentsController < ApplicationController

  def create
    @comment = Comment.create(comment_params)
    if @comment.save
      render 'api/comments/show', status: 201
    else
      render json: { errors: @comment.errors.full_messages }, status: 422
    end
  end

  private
  def comment_params
    params.require(:comment).permit(:body, :commentable_id, :commentable_type)
  end
end