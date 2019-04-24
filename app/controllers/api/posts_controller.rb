class Api::PostsController < ApplicationController
  def index
    @posts = Post.all
    render :index
  end

  def show
    @post = Post.find(params[:id])
    render :show, status: 200
  rescue ActiveRecord::RecordNotFound
    render json: { errors: "Not Found" }, status: 404
  end
end