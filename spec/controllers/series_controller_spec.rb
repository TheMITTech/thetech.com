require_relative '../rails_helper'

describe SeriesController do
  login_admin

  describe "GET #index" do
    it "populates an array of series" do
      series = create(:series)
      get :index
      expect(assigns(:series)).to match_array([series])
    end

    it "renders the :index view" do
      get :index
      expect(response).to render_template :index
    end
  end

  describe "GET #show" do
    it "assigns the requested series to @series" do
      series = create(:series)
      get :show, id: series
      expect(assigns(:series)).to eq(series)
    end

    it "renders the :show template" do
      get :show, id: create(:series)
      expect(response).to render_template :show
    end
  end

  describe "GET #new" do
    it "assigns a new series to @series" do
      get :new
      expect(assigns(:series)).to be_a_new(Series)
    end

    it "renders the :new template" do
      get :new
      expect(response).to render_template :new
    end
  end

  describe "GET #edit" do
    it "assigns the requested series to @series" do
      series = create(:series)
      get :edit, id: series
      expect(assigns(:series)).to eq(series)
    end

    it "renders the :edit template" do
      get :edit, id: create(:series)
      expect(response).to render_template :edit
    end
  end

  describe "POST #create" do
    context "with valid attributes" do
      it "saves a new series to the database" do
        expect {post :create, series: attributes_for(:series)}.to change(Series, :count).by(1)
      end
    end
  end
end
