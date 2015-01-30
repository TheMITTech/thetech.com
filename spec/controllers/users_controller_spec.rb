require_relative '../rails_helper'

describe UsersController do
  login_admin

  describe "GET #index" do
    it "populates an array of users" do
      user = create(:user)
      get :index
      expect(assigns(:users)).to include(user)
    end

    it "renders the :index view" do
      get :index
      expect(response).to render_template :index
    end
  end

  describe "GET #show" do
    it "assigns the requested user to @user" do
      user = create(:user)
      get :show, id: user
      expect(assigns(:user)).to eq(user)
    end

    it "renders the :show template" do
      get :show, id: create(:user)
      expect(response).to render_template :show
    end
  end

  describe "PUT #update" do
    before :each do
      @user = create(:user)
      @params = attributes_for(:user).merge({roles: [UserRole::ADMIN]})
    end

    it "locates the requested @user" do
      put :update, id: @user, user: @params
      expect(assigns(:user)).to eq(@user)
    end

    it "changes the user's attributes" do
      expect(@user.role_values).to_not include(UserRole::ADMIN)
      put :update, id: @user, user: @params
      @user.reload
      expect(@user.role_values).to match_array([UserRole::ADMIN])
    end

    it "redirects to the updated user" do
      put :update, id: @user, user: @params
      expect(response).to redirect_to user_path(@user)
    end
  end
end

