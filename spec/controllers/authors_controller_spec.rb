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

  describe "POST #create" do 
    context "with valid attributes" do 
      it "saves the new author in the database" do
        expect { post :create, author: attributes_for(:author) }.to change(Author, :count).by(1)
      end
    end 

    context "with invalid attributes" do 
      it "does not save the new author in the database" do
        expect { post :create, author: {name: ""} }.to_not change(Author, :count)
      end
    end 
  end 
end
