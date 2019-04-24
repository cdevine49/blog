class Api::Users::PostsController < ApplicationController
  before_action :validate_user_id_param, except: [:index]
  before_action :find_post, only: [:update, :destroy]

  def index
    @posts = Post.where(user_id: params[:user_id])
    render 'api/posts/index'
  end

  def create
    @post = current_user.posts.create(post_params)
    if @post.save
      render 'api/posts/show', status: 201
    else
      render json: { errors: @post.errors.full_messages }, status: 422
    end 
  end

  def update
    if @post.update_attributes(post_params)
      render 'api/posts/show', status: 200
    else
      render json: { errors: current_user.errors.full_messages }, status: 422
    end
  end

  def destroy
    if @post.destroy
      render 'api/posts/show', status: 200
    else
      render json: { errors: @post.errors.full_messages }, status: 422
    end
  end

  private
  def find_post
    @post = current_user.posts.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { errors: "Not Found" }, status: 404
  end

  def post_params
    params.require(:post).permit(:title, :body)
  end

  def validate_user_id_param
    render json: { errors: "This user is not logged in" }, status: 403 unless current_user.id == params[:user_id].to_i
  end
end