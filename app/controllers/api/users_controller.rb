class Api::UsersController < ApplicationController
  before_action :require_logged_out, only: [:create]

  def create
    @user = User.create(user_params)
    if @user.save
      login!(@user)
      render :show, status: 201
    else
      render json: { errors: @user.errors.full_messages }, status: 422
    end
  end

  private
  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end