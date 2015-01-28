require_relative '../rails_helper'

describe ArticlesController do
  login_admin

  describe "GET #index" do
    it "populates an array of articles" do
      article_version = create(:article_version)
      article = article_version.article
      get :index, params = {q: article.headline}
      expect(assigns(:articles)).to match_array([article])
    end
    it "renders the :index view" do
      get :index
      expect(response).to render_template :index
    end
  end

  describe "GET #new" do 
    it "assigns a new article to @article and a new piece to @piece" do
      get :new
      expect(assigns(:article)).to be_a_new(Article)
      expect(assigns(:piece)).to be_a_new(Piece)
    end

    it "renders the :new template" do
       get :new
      expect(response).to render_template :new
    end
  end

  describe "GET #edit" do
    it "assigns the requested article to @article" do
      article = create(:article)
      get :edit, id: article
      expect(assigns(:article)).to eq(article)
    end

    it "renders the :edit template" do
      get :edit, id: create(:article)
      expect(response).to render_template :edit
    end
  end

  describe "POST #create" do
    context "with valid attributes" do
      it "saves the new article in the database" do
        issue = create(:issue)
        section = create(:section)
        piece_attributes = attributes_for(:piece).merge({issue_id: issue.id, section_id: section.id})
        expect { post :create, {article: attributes_for(:article)}.merge(piece_attributes) }.to change(Article, :count).by(1)
      end
    end

    context "with invalid attributes" do
      it "doesn't save the new article in the database if article invalid" do
        issue = create(:issue)
        section = create(:section)
        piece_attributes = attributes_for(:piece).merge({issue_id: issue.id, section_id: section.id})
        expect { post :create, {article: {headline: ""}}.merge(piece_attributes) }.to_not change(Article, :count)
      end

      it "doesn't save the new article in the database if piece invalid" do
        expect { post :create, {article: attributes_for(:article)}.merge(attributes_for(:piece)) }.to_not change(Article, :count)
      end
    end
  end
end

