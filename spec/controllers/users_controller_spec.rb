require_relative '../rails_helper' 

describe UsersController do 
  admin = login_admin

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
end

