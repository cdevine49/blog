class ApplicationController < ActionController::API
  helper_method :current_user

  before_action :require_logged_in

  private
  def bearer_token
    if request.headers['Authorization'].present?
      request.headers['Authorization'].split(' ').last
    end
  end
  
  def current_user
    unless @current_user
      @current_user = User.find_by_token(bearer_token)
      response.headers["jwt"] = JsonWebToken.encode({user: @current_user.id}) if @current_user
    end
    return @current_user
  end

  def set_jwt_response_header
    response.headers["jwt"] = JsonWebToken.encode(user_id: @current_user.id)
  end

  def login!(user)
    @current_user = user
    set_jwt_response_header
  end

  def logged_in?
    !!current_user
  end

  def require_logged_in
    render json: { message: "You need to log in first" }, status: 401 unless logged_in?
  end

  def require_logged_out
    render json: { message: "You are already logged in" }, status: 403 if logged_in?
  end
end
