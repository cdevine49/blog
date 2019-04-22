class Api::SessionsController < ApplicationController
  before_action :require_logged_out, only: [:create]
  
  skip_before_action :require_logged_in, except: [:destroy]

  def create
    if @user = User.find_by(email: params[:user][:email]).try(:authenticate, params[:user][:password])
      login!(@user)
      render 'api/users/show', status: 200
    else
      render json: { errors: 'Invalid email or password' }, status: 422
    end
  end

  def show
    if @user = current_user
      render 'api/users/show', status: 200
    else
      render json: { message: 'Not logged in' }, status: 404
    end
  end

  def destroy
    logout!
    render json: { message: 'Logged out' }, status: 200
  end
end