require_relative '../rails_helper'

describe ImagesController do
  login_admin

  describe "GET #index" do
    it "populates an array of images" do
      image = create(:image)
      get :index
      expect(assigns(:images).size).to eq(1)

      expect(assigns(:images)[0]).to have_key(:id)
      expect(assigns(:images)[0][:id]).to eq(image.id)

      expect(assigns(:images)[0]).to have_key(:caption)
      expect(assigns(:images)[0][:caption]).to eq(image.caption)
    end

    it "renders the :index view" do
      get :index
      expect(response).to render_template :index
    end
  end

  describe "GET #show" do
    it "assigns the requested image to @image" do
      image = create(:image)
      get :show, id: image
      expect(assigns(:image)).to eq(image)
    end

    it "renders the :show template" do
      image = create(:image)
      get :show, id: image
      expect(response).to render_template :show
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
      it "saves the new image in the database" do
        issue = create(:issue)
        section = create(:section)
        piece_attributes = attributes_for(:piece).merge({issue_id: issue.id, section_id: section.id})
        other_params = {images: []}

        expect {post :create, {image: attributes_for(:image)}.merge(piece_attributes).merge(other_params)}.to change(Image, :count).by(1)
      end

      it "redirects to the image page" do
        issue = create(:issue)
        section = create(:section)
        piece_attributes = attributes_for(:piece).merge({issue_id: issue.id, section_id: section.id})
        other_params = {images: []}

        post :create, {image: attributes_for(:image)}.merge(piece_attributes).merge(other_params)
        expect(response).to redirect_to Image.last
      end
    end

    context "with invalid attributes" do
      it "doesn't save the new image in the database" do
        other_params = {images: []}

        expect {post :create, {image: attributes_for(:image)}.merge(other_params)}.to_not change(Image, :count)
      end

      it "re-renders the new page" do
        other_params = {images: []}

        post :create, {image: attributes_for(:image)}.merge(other_params)
        expect(response).to render_template :new
      end
    end
  end

  describe 'PUT update' do
    before :each do
      @image = create(:image)
    end

    context "with valid attributes" do
      it "locates the requested @image" do
        put :update, id: @image, image: attributes_for(:image)
        expect(assigns(:image)).to eq(@image)
      end

      it "changes the image's attributes" do
        expect(@image.caption).to_not eq("new caption")
        put :update, id: @image, image: attributes_for(:image, caption: "new caption")
        @image.reload
        expect(@image.caption).to eq("new caption")
      end

      it "redirects to the updated image" do
        put :update, id: @image, image: attributes_for(:image)
        expect(response).to redirect_to @image
      end
    end
  end

  describe "PUT #destroy" do
    it "removes the image from the database" do
      image = create(:image)
      expect { delete :destroy, id: image }.to change(Image, :count).by(-1)
    end

    it "redirects to the index page" do
      image = create(:image)
      delete :destroy, id: image
      expect(response).to redirect_to images_url
    end
  end

  describe "POST #assign_piece" do
    it "assigns the specified piece to the image" do
      piece = create(:piece)
      image = piece.image
      image.pieces.delete(piece)
      expect(image.pieces).to be_empty

      post :assign_piece, id: image, piece_id: piece
      expect(assigns(:image).pieces).to eq([piece])
    end

    it "redirects to the image page" do
      piece = create(:piece)
      image = piece.image
      image.pieces.delete(piece)
      expect(image.pieces).to be_empty

      post :assign_piece, id: image, piece_id: piece
      expect(response).to redirect_to image_path(image)
    end
  end

  describe "POST #unassign_piece" do
    it "unassigns the specified piece from the image" do
      piece = create(:piece)
      image = piece.image
      image.pieces << piece
      image.save
      expect(image.pieces).to eq([piece])

      post :unassign_piece, id: image, piece_id: piece.id
      expect(assigns(:image).pieces).to be_empty
    end

    it "redirects to the image page" do
      piece = create(:piece)
      image = piece.image
      image.pieces << piece
      image.save!

      post :unassign_piece, id: image, piece_id: piece
      expect(response).to redirect_to image_path(image)
    end
  end
end
