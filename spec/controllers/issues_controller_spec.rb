require_relative '../rails_helper'

describe IssuesController do
  login_admin

  describe "GET #index" do
    it "populates an array of issues" do
      issue = create(:issue)
      get :index
      expect(assigns(:issues)).to match_array([issue])
    end

    it "assigns a new Issue to @issue" do
      get :index
      expect(assigns(:new_issue)).to be_a_new(Issue)
    end

    it "renders the :index view" do
      get :index
      expect(response).to render_template :index
    end
  end

  describe "GET #show" do
    it "renders the :show view" do
      issue = create(:issue)
      get :show, id: issue
      expect(response).to render_template :show
    end
  end

  describe "POST #create" do
    context "with valid attributes" do
      it "saves the new issue in the database" do
        expect { post :create, issue: attributes_for(:issue) }.to change(Issue, :count).by(1)
      end

      it "redirects to the issues page" do
        post :create, issue: attributes_for(:issue)
        expect(response).to redirect_to issues_path
      end
    end

    context "with invalid attributes" do
      it "does not save the new issue in the database" do
        expect { post :create, issue: {volume: nil, number: nil} }.to_not change(Issue, :count)
      end

      it "redirects to the issues page" do
        post :create, issue: {volume: nil, number: nil}
        expect(response).to redirect_to issues_path
      end
    end
  end

  describe "GET #upload_pdf_form" do
    it "assigns the correct issue to @issue" do
      issue = create(:issue)
      xhr :get, :upload_pdf_form, id: issue, format: :js
      expect(assigns(:issue)).to eq(issue)
    end

    it "renders the upload_pdf_form view" do
      issue = create(:issue)
      xhr :get, :upload_pdf_form, id: issue, format: :js
      expect(response).to render_template :upload_pdf_form
    end
  end

  describe "POST #upload_pdf" do
    it "assigns the correct issue to @issue" do
      issue = create(:issue)
      post :upload_pdf, id: issue, content: ""
      expect(assigns(:issue)).to eq(issue)
    end

    it "redirects to the issues path" do
      issue = create(:issue)
      post :upload_pdf, id: issue, content: ""
      expect(response).to redirect_to issues_path
    end
  end

  describe "PUT #remove_pdf" do
    it "assigns the correct issue to @issue" do
      issue = create(:issue)
      delete :remove_pdf, id: issue
      expect(assigns(:issue)).to eq(issue)
    end

    it "redirects to the issues path" do
      issue = create(:issue)
      delete :remove_pdf, id: issue
      expect(response).to redirect_to issues_path
    end
  end
end

