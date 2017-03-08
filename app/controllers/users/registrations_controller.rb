class Users::RegistrationsController < Devise::RegistrationsController
  def after_update_path_for(resource)
    admin_root_path
  end

  # You can put the params you want to permit in the empty array.
  def configure_sign_up_params
    devise_parameter_sanitizer.for(:sign_up) << :name
  end

  # You can put the params you want to permit in the empty array.
  def configure_account_update_params
    devise_parameter_sanitizer.for(:account_update) << :role << name
  end
end
