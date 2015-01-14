class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :configure_permitted_parameters, if: :devise_controller?
  before_action :set_empty_flash

  # Fix CanCan bug with strong parameters.
  # See: https://github.com/ryanb/cancan/issues/835
  before_filter do
    resource = controller_name.singularize.to_sym
    method = "#{resource}_params"
    params[resource] &&= send(method) if respond_to?(method, true)
  end

  rescue_from CanCan::AccessDenied do |e|
    redirect_to root_url, flash: {error: e.message}
  end

  include SimpleFormattedBootstrapFlashHelper

  protected
    def configure_permitted_parameters
      devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:name, :email, :password) }
      devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:name, :email, :password, :current_password) }
    end

    def set_empty_flash
      @flash = {}
    end

    def raise_404
      raise ActionController::RoutingError.new('Not Found')
    end
end
