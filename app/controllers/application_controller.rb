class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception

  before_filter :configure_permitted_parameters, if: :devise_controller?
  before_action :set_empty_flash
  before_action :check_for_visibility
  before_action :check_for_mini_profiler_access

  rescue_from CanCan::AccessDenied do |e|
    redirect_to admin_root_url, flash: {error: e.message}
  end

  include SimpleFormattedBootstrapFlashHelper
  include FrontendHelper

  protected
    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, keys:[:name, :email, :password])
      devise_parameter_sanitizer.permit(:account_update, keys:[:name, :email, :password, :current_password])
    end

    def set_empty_flash
      @flash = {}
    end

    def raise_404
      raise ActionController::RoutingError.new('Not Found')
    end

    def after_sign_in_path_for(resource)
      admin_root_path
    end

    def after_sign_out_path_for(resource)
      admin_root_path
    end

    def is_frontend?
      ENV["TECH_APP_ROLE"] == 'frontend'
    end

    def allowed_in_frontend?
      false
    end

    def check_for_visibility
      raise_404 if (is_frontend? && (!allowed_in_frontend?))
    end

   def check_for_mini_profiler_access
      if can? :access, :mini_profiler
        Rack::MiniProfiler.authorize_request
      end
    end

    def current_ability
      Ability.new(current_user)
    end
end
