class Users::RegistrationsController < Devise::RegistrationsController
  # PUT /resource
  def update
    super
    roles = params['user']['roles'].keys.select { |k| k != 0 }.map(&:to_i)
    current_user.update_roles roles
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
