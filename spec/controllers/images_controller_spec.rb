require_relative '../rails_helper'

describe ImagesController do
  login_admin

  describe "GET #index" do
    it "populates an array of images" do
      image = create(:image)
      get :index
      expect(assigns(:images)).to match_array([image])
    end

    it "renders the :index view" do
      get :index
      expect(response).to render_template :index
    end
  end

  describe "GET #new" do 
    it "assigns a new image to @image and a new piece to @piece" do
      get :new
      expect(assigns(:image)).to be_a_new(Image)
      expect(assigns(:piece)).to be_a_new(Piece)
    end

    it "renders the :new template" do
       get :new
      expect(response).to render_template :new
    end
  end

  describe "GET #edit" do
    it "assigns the requested image to @image" do
      image = create(:image)
      get :edit, id: image
      expect(assigns(:image)).to eq(image)
    end

    it "renders the :edit template" do
      get :edit, id: create(:image)
      expect(response).to render_template :edit
    end
  end

  describe "POST #create" do
    context "with valid attributes" do
      it "saves the new: image in the database" do
        issue = create(:issue)
        section = create(:section)
        piece_attributes = attributes_for(:piece).merge({issue_id: issue.id, section_id: section.id})

        expect {post :create, {image: attributes_for(:image)}.merge(piece_attributes)}.to change(Image, :count).by(1)
      end
    end
  end
end
