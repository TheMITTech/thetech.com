require_relative '../rails_helper'

describe ArticleVersionsController do
  login_admin

  describe "GET #index" do
    it "populates an array of article_versions" do
      article = create(:article)
      get :index, article_id: article.id
      expect(assigns(:versions)).to match_array([ArticleVersion.first])
    end

    it "renders the :index view" do
      article = create(:article)
      get :index, article_id: article.id
      expect(response).to render_template :index
    end
  end

  describe "GET #show" do
  end
end


