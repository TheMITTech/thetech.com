class UsersController < ApplicationController
  before_action :set_user, only: [:show, :update]

  load_and_authorize_resource

  respond_to :html

  def index
    @users = User.all
  end

  def show
    respond_with(@user)
  end

  def update
    @user.update_roles(user_params[:roles].map(&:to_i))
    redirect_to user_path(@user),
      flash: {success: 'You have successfully edited this user\'s roles.'}
  end

  private
    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit({roles: []})
    end

end
