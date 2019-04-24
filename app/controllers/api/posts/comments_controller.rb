class Api::Posts::CommentsController < ApplicationController
  before_action :find_post

  def create
    @comment = @post.comments.create(comment_params)
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

  def find_post
    @post = Post.find(params[:post_id])
  rescue ActiveRecord::RecordNotFound
    render json: { errors: "Not Found" }, status: 404
  end
end