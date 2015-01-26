require_relative '../rails_helper'

describe SectionsController do
  login_admin

  describe "GET #index" do
    it "populates an array of sections" do
      section = create(:section)
      get :index
      expect(assigns(:sections)).to match_array([section])
    end

    it "renders the :index view" do
      get :index
      expect(response).to render_template :index
    end
  end

  describe "GET #show" do
    it "assigns the requested section to @section" do
      section = create(:section)
      get :show, id: section
      expect(assigns(:section)).to eq(section)
    end

    it "renders the :show template" do
      get :show, id: create(:section)
      expect(response).to render_template :show
    end
  end

  describe "GET #new" do
    it "assigns a new Section to @section" do
      get :new
      expect(assigns(:section)).to be_a_new(Section)
    end

    it "renders the :new template" do
      get :new
      expect(response).to render_template :new
    end
  end

  describe "GET #edit" do
    it "assigns the requested section to @section" do
      section = create(:section)
      get :edit, id: section
      expect(assigns(:section)).to eq(section)
    end

    it "renders the :edit template" do
      get :edit, id: create(:section)
      expect(response).to render_template :edit
    end
  end

  describe "POST #create" do
    context "with valid attributes" do
      it "saves the new section in the database" do
        expect { post :create, section: attributes_for(:section) }.to change(Section, :count).by(1)
      end
    end
  end

  describe 'PUT update' do
    before :each do
      @section = create(:section)
    end

    context "with valid attributes" do
      it "locates the requested @section" do
        put :update, id: @section, section: attributes_for(:section)
        expect(assigns(:section)).to eq(@section)
      end

      it "changes the section's attributes" do
        expect(@section.name).to_not eq("updated name")
        put :update, id: @section, section: attributes_for(:section, name: "updated name")
        @section.reload
        expect(@section.name).to eq("updated name")
      end

      it "redirects to the updated section" do
        put :update, id: @section, section: attributes_for(:section)
        expect(response).to redirect_to @section
      end
    end
  end
end
