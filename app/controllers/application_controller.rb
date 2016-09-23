class ApplicationController < ActionController::Base
  include Pundit

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :get_markets
  # before_action :authenticate_user!
  # before_action :authenticate_admin
  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:email, :password, :password_confirmation) }
    devise_parameter_sanitizer.for(:account_update) { |u|
      u.permit(:email, :password, :password_confirmation, :current_password)
    }
  end

  private

  def user_not_authorized
    flash[:alert] = "Access denied"
    redirect_to (request.referrer||root_path)
  end

  def get_markets
    @markets_top = Market.all
  end
end
