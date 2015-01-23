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

  describe "POST #create" do
    context "with valid attributes" do
      it "saves the new issue in the database" do
        expect { post :create, issue: attributes_for(:issue) }.to change(Issue, :count).by(1)
      end
    end

    context "with invalid attributes" do
      it "does not save the new issue in the database" do
        expect { post :create, issue: {volume: nil, number: nil} }.to_not change(Issue, :count)
      end
    end
  end
end

