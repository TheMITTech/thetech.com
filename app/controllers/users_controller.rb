class UsersController < ApplicationController

  respond_to :html

  def index
    @users = User.all
  end

  def show
    respond_with(@user)
  end

  # def edit
  #   binding.pry
  # end

end
