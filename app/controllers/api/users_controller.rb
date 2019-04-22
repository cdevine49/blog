class Api::UsersController < ApplicationController
  skip_before_action :require_logged_in, only: [:create]
  before_action :require_logged_out, only: [:create]
  before_action :validate_id_param, except: [:create]
  before_action :authenticate_user, except: [:create]

  def create
    @user = User.create(user_params)
    if @user.save
      login!(@user)
      render :show, status: 201
    else
      render json: { errors: @user.errors.full_messages }, status: 422
    end
  end

  def update
    if @user.update_attributes(user_params)
      render :show, status: 200
    else
      render json: { errors: current_user.errors.full_messages }, status: 422
    end
  end

  def destroy
    if @user.destroy
      logout!
      render :show, status: 200
    else
      render json: { errors: @user.errors.full_messages }, status: 422
    end
  end

  private
  def authenticate_user
    unless @user = current_user.try(:authenticate, params[:user][:current_password])
      render json: { errors: "Wrong password" }, status: 401
    end
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end

  def validate_id_param
    render json: { errors: "This user is not logged in" }, status: 403 unless current_user.id == params[:id].to_i
  end
end