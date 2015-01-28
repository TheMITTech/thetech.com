require_relative '../rails_helper'

describe AuthorsController do
  login_admin

  describe "GET #index" do
    it "populates an array of authors" do
      author = create(:author)
      get :index
      expect(assigns(:authors)).to match_array([author])
    end

    it "renders the :index view" do
      get :index
      expect(response).to render_template :index
    end
  end

  describe "GET #show" do
    it "assigns the requested author to @author" do
      author = create(:author)
      get :show, id: author
      expect(assigns(:author)).to eq(author)
    end

    it "renders the :show template" do
      get :show, id: create(:author)
      expect(response).to render_template :show
    end
  end

  describe "GET #new" do
    it "assigns a new Author to @author" do
      get :new
      expect(assigns(:author)).to be_a_new(Author)
    end

    it "renders the :new template" do
      get :new
      expect(response).to render_template :new
    end
  end

  describe "GET #edit" do
    it "assigns the requested author to @author" do
      author = create(:author)
      get :edit, id: author
      expect(assigns(:author)).to eq(author)
    end

    it "renders the :edit template" do
      get :edit, id: create(:author)
      expect(response).to render_template :edit
    end
  end

  describe "POST #create" do
    context "with valid attributes" do
      it "saves the new author in the database" do
        expect { post :create, author: attributes_for(:author) }.to change(Author, :count).by(1)
      end

      it "redirects to the new author's page" do
        post :create, author: attributes_for(:author)
        expect(response).to redirect_to Author.last
      end
    end

    context "with invalid attributes" do
      it "does not save the new author in the database" do
        expect { post :create, author: {name: ""} }.to_not change(Author, :count)
      end

      it "re-renders the new page" do
        post :create, author: {name: ""}
        expect(response).to render_template :new
      end
    end
  end

  describe 'PUT update' do
    before :each do
      @author = create(:author)
    end

    context "with valid attributes" do
      it "locates the requested @author" do
        put :update, id: @author, author: attributes_for(:author)
        expect(assigns(:author)).to eq(@author)
      end

      it "changes the author's attributes" do
        expect(@author.name).to_not eq("Larry")
        put :update, id: @author, author: attributes_for(:author, name: "Larry")
        @author.reload
        expect(@author.name).to eq("Larry")
      end

      it "redirects to the updated author" do
        put :update, id: @author, author: attributes_for(:author)
        expect(response).to redirect_to @author
      end
    end

    context "invalid attributes" do
      it "locates the requested @author" do
        put :update, id: @author, author: {name: ""}
        expect(assigns(:author)).to eq(@author)
      end

      it "does not change the author's attributes" do
        put :update, id: @author, author: attributes_for(:author, name: "")
        @author.reload
        expect(@author.name).to_not eq("")
      end

      it "re-renders the edit method" do
        put :update, id: @author, author: {name: ""}
        expect(response).to render_template :edit
      end
    end
  end

  describe "PUT #destroy" do
    it "removes the author from the database" do
      author = create(:author)
      expect { delete :destroy, id: author }.to change(Author, :count).by(-1)
    end

    it "redirects to the index page" do
      author = create(:author)
      delete :destroy, id: author
      expect(response).to redirect_to authors_url
    end
  end
end
