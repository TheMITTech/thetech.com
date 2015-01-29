require_relative '../rails_helper'

describe ArticleListsController do
  login_admin

  describe "GET #index" do
    it "populates an array of article_lists" do
      article_list = create(:article_list)
      get :index
      expect(assigns(:article_lists)).to match_array([article_list])
    end

    it "renders the :index view" do
      get :index
      expect(response).to render_template :index
    end
  end

  describe "GET #show" do
    it "assigns the requested article_list to @article_list" do
      article_list = create(:article_list)
      get :show, id: article_list
      expect(assigns(:article_list)).to eq(article_list)
    end

    it "renders the :show template" do
      get :show, id: create(:article_list)
      expect(response).to render_template :show
    end
  end

  describe "GET #new" do
    it "assigns a new article_list to @article_list" do
      get :new
      expect(assigns(:article_list)).to be_a_new(ArticleList)
    end

    it "renders the :new template" do
      get :new
      expect(response).to render_template :new
    end
  end

  describe "GET #edit" do
    it "assigns the requested article_list to @article_list" do
      article_list = create(:article_list)
      get :edit, id: article_list
      expect(assigns(:article_list)).to eq(article_list)
    end

    it "renders the :edit template" do
      get :edit, id: create(:article_list)
      expect(response).to render_template :edit
    end
  end

  describe "POST #create" do
    it "saves the new article_list in the database" do
      piece = create(:piece)
      expect { post :create, article_list: attributes_for(:article_list), piece_id: piece.id }.to change(ArticleList, :count).by(1)
    end

    it "redirects to the new article_list's page" do
      piece = create(:piece)
      post :create, article_list: attributes_for(:article_list), piece_id: piece.id
      expect(response).to redirect_to ArticleList.last
    end
  end

  describe 'PUT #update' do
    before :each do
      @article_list = create(:article_list)
    end

    it "locates the requested @article_list" do
      put :update, id: @article_list, article_list: attributes_for(:article_list)
      expect(assigns(:article_list)).to eq(@article_list)
    end

    it "changes the article_list's attributes" do
      expect(@article_list.name).to_not eq("new name")
      put :update, id: @article_list, article_list: attributes_for(:article_list, name: "new name")
      @article_list.reload
      expect(@article_list.name).to eq("new name")
    end

    it "redirects to the updated article_list" do
      put :update, id: @article_list, article_list: attributes_for(:article_list)
      expect(response).to redirect_to @article_list
    end
  end

  describe "PUT #destroy" do
    it "removes the article_list from the database" do
      article_list = create(:article_list)
      expect { delete :destroy, id: article_list }.to change(ArticleList, :count).by(-1)
    end

    it "redirects to the index page" do
      article_list = create(:article_list)
      delete :destroy, id: article_list
      expect(response).to redirect_to article_lists_url
    end
  end

  describe "POST #append_item" do
    it "appends the specified piece to the article list" do
      article_list = create(:article_list)
      article_list_item = create(:article_list_item)
      post :append_item, id: article_list, piece_id: article_list_item.piece.id
      expect(assigns(:article_list).article_list_items.find_by(piece_id: article_list_item.piece.id)).to_not be_nil
    end

    it "redirects to the article list page" do
      article_list = create(:article_list)
      piece = create(:piece)
      post :append_item, id: article_list, piece_id: piece.id
      expect(response).to redirect_to article_list
    end
  end

  describe "POST #remove_item" do
    it "removes the specified piece from the article list" do
      article_list = create(:article_list)
      article_list_item = create(:article_list_item)
      post :remove_item, id: article_list, article_list_item_id: article_list_item
      expect(ArticleListItem.all).to_not include(article_list)
    end

    it "redirects to the article list page" do
      article_list = create(:article_list)
      article_list_item = create(:article_list_item)
      post :remove_item, id: article_list, article_list_item_id: article_list_item
      expect(response).to redirect_to article_list
    end
  end
end
