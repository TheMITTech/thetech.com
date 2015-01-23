require_relative '../rails_helper'

describe ArticleVersionsController do
  login_admin

  describe "GET #index" do
    it "populates an array of article_versions" do
      article_version = create(:article_version)
      article_version.contents = {article_params: attributes_for(:article)}
      article_version.save!
      get :index, article_id: article_version.article.id
      expect(assigns(:versions)).to match_array([article_version])
    end

    it "renders the :index view" do
      article_version = create(:article_version)
      article_version.contents = {article_params: attributes_for(:article)}
      article_version.save!
      get :index, article_id: article_version.article.id
      expect(response).to render_template :index
    end
  end

  describe "GET #show" do
    it "assigns the requested version to @version" do
      version = create(:article_version)
      version.contents = {article_attributes: attributes_for(:article), piece_attributes: attributes_for(:piece)}
      version.save!
      get :show, {id: version, article_id: version.article}
      expect(assigns(:version)).to eq(version)
    end

    it "renders the :show template" do
      version = create(:article_version)
      version.contents = {article_attributes: attributes_for(:article), piece_attributes: attributes_for(:piece)}
      version.save!
      get :show, {id: version, article_id: version.article}
      expect(response).to render_template :show
    end
  end
end


